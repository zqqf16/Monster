//
//  VMConfigHelper.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/5.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import Virtualization

struct VMConfigHelper {
    let config: VMConfig
    
    private func computeCPUCount() -> Int {
        var cpuCount = config.cpuCount.count
        cpuCount = max(cpuCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        cpuCount = min(cpuCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        
        return cpuCount
    }
    
    private func computeMemorySize() -> UInt64 {
        var memorySize = config.memorySize.bytes
        memorySize = max(memorySize, VZVirtualMachineConfiguration.minimumAllowedMemorySize)
        memorySize = min(memorySize, VZVirtualMachineConfiguration.maximumAllowedMemorySize)
        
        return memorySize
    }
    
    private func retrieveMachineIdentifier() -> VZGenericMachineIdentifier {
        if let machineIdentifierData = config.machineIdentifierData,
           let machineIdentifier = VZGenericMachineIdentifier(dataRepresentation: machineIdentifierData) {
            return machineIdentifier
        }
        
        let machineIdentifier = VZGenericMachineIdentifier()
        config.machineIdentifierData = machineIdentifier.dataRepresentation
        return machineIdentifier
    }
    
    private func retrieveEFIVariableStore(_ bundle: VMBundle) throws -> VZEFIVariableStore {
        let efiVariableStoreURL = bundle.efiVariableStoreURL
        if FileManager.default.fileExists(atPath: efiVariableStoreURL.path) {
            return VZEFIVariableStore(url: efiVariableStoreURL)
        }
        
        return try VZEFIVariableStore(creatingVariableStoreAt: efiVariableStoreURL)
    }
    
    private func createUSBMassStorageDeviceConfiguration() throws -> VZUSBMassStorageDeviceConfiguration? {
        guard let restoreImagePath = config.restoreImagePath else {
            return nil
        }
        let restoreImageURL = URL(filePath: restoreImagePath)
        let intallerDiskAttachment = try VZDiskImageStorageDeviceAttachment(url: restoreImageURL, readOnly: true)
        return VZUSBMassStorageDeviceConfiguration(attachment: intallerDiskAttachment)
    }
    
    private func createBundle() throws -> VMBundle {
        let bundle = VMBundle(config)
        try bundle.prepareBundleDirectory()
        
        if config.bundlePath == nil {
            DispatchQueue.main.async {
                // In next runloop to avoid "Modifying state during view update, this will cause undefined behavior."
                config.bundlePath = bundle.url.path
            }
        }
                
        return bundle
    }
    
    private func createBlockDeviceConfiguration(_ bundle: VMBundle) throws -> VZVirtioBlockDeviceConfiguration {
        let path = bundle.diskImageURL.path
        try bundle.prepareDiskImage(with: config.diskSize)
        
        let mainDiskAttachment = try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: path), readOnly: false)
        let mainDisk = VZVirtioBlockDeviceConfiguration(attachment: mainDiskAttachment)
        return mainDisk
    }
    
    private func createNetworkDeviceConfiguration() -> VZVirtioNetworkDeviceConfiguration {
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.attachment = VZNATNetworkDeviceAttachment()
        
        return networkDevice
    }
    
    private func createGraphicsDeviceConfiguration() -> VZVirtioGraphicsDeviceConfiguration {
        let graphicsDevice = VZVirtioGraphicsDeviceConfiguration()
        graphicsDevice.scanouts = [
            VZVirtioGraphicsScanoutConfiguration(widthInPixels: 1280, heightInPixels: 720)
        ]
        
        return graphicsDevice
    }
    
    private func createInputAudioDeviceConfiguration() -> VZVirtioSoundDeviceConfiguration {
        let inputAudioDevice = VZVirtioSoundDeviceConfiguration()
        
        let inputStream = VZVirtioSoundDeviceInputStreamConfiguration()
        inputStream.source = VZHostAudioInputStreamSource()
        
        inputAudioDevice.streams = [inputStream]
        return inputAudioDevice
    }
    
    private func createOutputAudioDeviceConfiguration() -> VZVirtioSoundDeviceConfiguration {
        let outputAudioDevice = VZVirtioSoundDeviceConfiguration()
        
        let outputStream = VZVirtioSoundDeviceOutputStreamConfiguration()
        outputStream.sink = VZHostAudioOutputStreamSink()
        
        outputAudioDevice.streams = [outputStream]
        return outputAudioDevice
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
        guard config.os == .macOS else {
            return false
        }
        
        let bundle = VMBundle(config)
        return !bundle.diskImageExists
    }
    
    func createVirtualMachineConfiguration() throws -> VZVirtualMachineConfiguration {
        let bundle = try createBundle()
        
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        virtualMachineConfiguration.cpuCount = computeCPUCount()
        virtualMachineConfiguration.memorySize = computeMemorySize()
        
        let platform = VZGenericPlatformConfiguration()
        platform.machineIdentifier = retrieveMachineIdentifier()
        
        let bootloader = VZEFIBootLoader()
        bootloader.variableStore = try retrieveEFIVariableStore(bundle)
        
        let disksArray = NSMutableArray()
        
        do {
            if let usbDevice = try createUSBMassStorageDeviceConfiguration() {
                disksArray.add(usbDevice)
            }
        } catch {
            print("Create USB mass storage device failed: \(error)")
        }

        disksArray.add(try createBlockDeviceConfiguration(bundle))
        guard let disks = disksArray as? [VZStorageDeviceConfiguration] else {
            fatalError("Invalid disksArray.")
        }
        
        virtualMachineConfiguration.platform = platform
        virtualMachineConfiguration.bootLoader = bootloader
        virtualMachineConfiguration.storageDevices = disks
        
        virtualMachineConfiguration.networkDevices = [createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.graphicsDevices = [createGraphicsDeviceConfiguration()]
        virtualMachineConfiguration.audioDevices = [createInputAudioDeviceConfiguration(), createOutputAudioDeviceConfiguration()]
        
        virtualMachineConfiguration.keyboards = [VZUSBKeyboardConfiguration()]
        virtualMachineConfiguration.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]
        virtualMachineConfiguration.consoleDevices = [createSpiceAgentConsoleDeviceConfiguration()]
        
        try virtualMachineConfiguration.validate()
        try bundle.save(config: config)
        
        return virtualMachineConfiguration
    }
}
