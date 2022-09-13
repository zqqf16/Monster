//
//  MacOSConfigHelper.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/8.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import Virtualization

#if arch(arm64)

extension VMDisplay {
    func toMacConfig() -> VZMacGraphicsDisplayConfiguration {
        VZMacGraphicsDisplayConfiguration(
            widthInPixels: width,
            heightInPixels: height,
            pixelsPerInch: pixelsPerInch
        )
    }
}

struct MacOSConfigHelper: VMConfigHelper {
    var config: VMConfig
    var bundle: VMBundle
    
    init(config: VMConfig, bundle: VMBundle) {
        self.config = config
        self.bundle = bundle
    }
    
    // MARK: Platform
    private func retrieveOrCreateMachineIdentifier() throws -> VZMacMachineIdentifier {
        do {
            if bundle.machineIdentifierExists {
                let machineIdentifierData = try Data(contentsOf: bundle.machineIdentifierURL)
                if let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: machineIdentifierData) {
                    return machineIdentifier
                }
            }
            let machineIdentifier = VZMacMachineIdentifier()
            try bundle.save(machineIdentifier: machineIdentifier.dataRepresentation)
            return machineIdentifier
        } catch {
            throw Failure("Failed to retrieve machine identifier: \(error.localizedDescription)")
        }
    }

    private func retriveHardwareModel() throws -> VZMacHardwareModel {
        guard let hardwareModelData = try? Data(contentsOf: bundle.hardwareModelURL),
              let hardwareModel = VZMacHardwareModel(dataRepresentation: hardwareModelData) else {
            throw Failure("Failed to retrieve hardware model")
        }
        
        if !hardwareModel.isSupported {
            throw Failure("Hardware model is not supported by the host")
        }
        
        return hardwareModel
    }

    private func createPlatform() throws -> VZMacPlatformConfiguration {
        let macPlatform = VZMacPlatformConfiguration()
        macPlatform.auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: bundle.auxiliaryStorageURL)
        macPlatform.hardwareModel = try retriveHardwareModel()
        macPlatform.machineIdentifier = try retrieveOrCreateMachineIdentifier()
        return macPlatform
    }
    
    // MARK: Storage
    
    private func createBlockDeviceConfiguration() throws -> VZVirtioBlockDeviceConfiguration {
        do {
            let path = bundle.diskImageURL.path
            try bundle.prepareDiskImage(with: config.diskSize)
            
            let mainDiskAttachment = try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: path), readOnly: false)
            let mainDisk = VZVirtioBlockDeviceConfiguration(attachment: mainDiskAttachment)
            return mainDisk
        } catch {
            throw Failure("Failed to create block device: \(error.localizedDescription)")
        }
    }
    
    // MARK: Networks & Other Devices
    private func createNetworkDeviceConfiguration() -> VZVirtioNetworkDeviceConfiguration {
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.attachment = VZNATNetworkDeviceAttachment()
        
        return networkDevice
    }
    
    private func createGraphicsDeviceConfiguration() -> VZGraphicsDeviceConfiguration {
        let graphicsConfiguration = VZMacGraphicsDeviceConfiguration()
        graphicsConfiguration.displays = [
            config.display.toMacConfig()
        ]
        return graphicsConfiguration
    }
    
    private func createAudioDeviceConfiguration() -> VZVirtioSoundDeviceConfiguration {
        let audioConfiguration = VZVirtioSoundDeviceConfiguration()

        let inputStream = VZVirtioSoundDeviceInputStreamConfiguration()
        inputStream.source = VZHostAudioInputStreamSource()

        let outputStream = VZVirtioSoundDeviceOutputStreamConfiguration()
        outputStream.sink = VZHostAudioOutputStreamSink()

        audioConfiguration.streams = [inputStream, outputStream]
        return audioConfiguration
    }
    
    private func createSpiceAgentConsoleDeviceConfiguration() -> VZVirtioConsoleDeviceConfiguration {
        let consoleDevice = VZVirtioConsoleDeviceConfiguration()
        
        let spiceAgentPort = VZVirtioConsolePortConfiguration()
        spiceAgentPort.name = VZSpiceAgentPortAttachment.spiceAgentPortName
        spiceAgentPort.attachment = VZSpiceAgentPortAttachment()
        consoleDevice.ports[0] = spiceAgentPort
        
        return consoleDevice
    }
    
    var needInstall: Bool {
        return !bundle.diskImageExists || !config.installed
    }
    
    func createVirtualMachineConfiguration() throws -> VZVirtualMachineConfiguration {
        try bundle.prepareBundleDirectory()

        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        virtualMachineConfiguration.cpuCount = computeCPUCount()
        virtualMachineConfiguration.memorySize = computeMemorySize()
        
        let disksArray = NSMutableArray()
        disksArray.add(try createBlockDeviceConfiguration())
        guard let disks = disksArray as? [VZStorageDeviceConfiguration] else {
            fatalError("Invalid disksArray.")
        }
        
        virtualMachineConfiguration.platform = try createPlatform()
        virtualMachineConfiguration.bootLoader = VZMacOSBootLoader()
        virtualMachineConfiguration.storageDevices = disks
        
        virtualMachineConfiguration.networkDevices = [createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.graphicsDevices = [createGraphicsDeviceConfiguration()]
        virtualMachineConfiguration.audioDevices = [createAudioDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [VZUSBKeyboardConfiguration()]
        virtualMachineConfiguration.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]
        virtualMachineConfiguration.consoleDevices = [createSpiceAgentConsoleDeviceConfiguration()]
        virtualMachineConfiguration.directorySharingDevices = [try directorySharingConfiguration()]

        do {
            try virtualMachineConfiguration.validate()
        } catch {
            throw Failure("Virtual machine configuration is invalid: \(error.localizedDescription)")
        }
        
        try? bundle.save(config: config)
        
        return virtualMachineConfiguration
    }
    
    // MARK: MacOS Installation

    private func retrieveOrCreateAuxiliaryStorage(macOSConfiguration: VZMacOSConfigurationRequirements) throws -> VZMacAuxiliaryStorage {
        if bundle.auxiliaryStorageExists {
            return VZMacAuxiliaryStorage(contentsOf: bundle.auxiliaryStorageURL)
        }
        do {
            return try VZMacAuxiliaryStorage(creatingStorageAt: bundle.auxiliaryStorageURL,
                                             hardwareModel: macOSConfiguration.hardwareModel,
                                                   options: [])
        } catch {
            throw Failure("Failed to create auxiliary storage", reason: error)
        }
    }
    
    private func createMacPlatformConfiguration(macOSConfiguration: VZMacOSConfigurationRequirements) throws -> VZMacPlatformConfiguration {
        let macPlatformConfiguration = VZMacPlatformConfiguration()
        
        macPlatformConfiguration.auxiliaryStorage = try retrieveOrCreateAuxiliaryStorage(macOSConfiguration: macOSConfiguration)
        macPlatformConfiguration.hardwareModel = macOSConfiguration.hardwareModel
        macPlatformConfiguration.machineIdentifier = VZMacMachineIdentifier()
        
        try bundle.save(hardware: macOSConfiguration.hardwareModel.dataRepresentation)
        try bundle.save(machineIdentifier: macPlatformConfiguration.machineIdentifier.dataRepresentation)
        
        return macPlatformConfiguration
    }

    func createVirtualMachineConfiguration(restoreImage: VZMacOSRestoreImage) throws -> VZVirtualMachineConfiguration {
        guard let macOSConfiguration = restoreImage.mostFeaturefulSupportedConfiguration else {
            throw Failure("Failed to obtain configuration from restore image")
        }

        if !macOSConfiguration.hardwareModel.isSupported {
            throw Failure("The hardware model isn't supported on the current host")
        }

        try bundle.prepareBundleDirectory()
        try bundle.prepareDiskImage(with: config.diskSize)
        
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()

        virtualMachineConfiguration.platform = try createMacPlatformConfiguration(macOSConfiguration: macOSConfiguration)
        virtualMachineConfiguration.cpuCount = computeCPUCount()
        virtualMachineConfiguration.memorySize = computeMemorySize()

        virtualMachineConfiguration.bootLoader = VZMacOSBootLoader()
        //virtualMachineConfiguration.graphicsDevices = [createGraphicsDeviceConfiguration()]
        virtualMachineConfiguration.storageDevices = [try createBlockDeviceConfiguration()]
        virtualMachineConfiguration.networkDevices = [createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]
        //virtualMachineConfiguration.keyboards = [VZUSBKeyboardConfiguration()]
        //virtualMachineConfiguration.audioDevices = [createAudioDeviceConfiguration()]

        do {
            try virtualMachineConfiguration.validate()
        } catch {
            throw Failure("Virtual machine configuration is invalid: \(error.localizedDescription)")
        }
        
        return virtualMachineConfiguration
    }
}

#endif
