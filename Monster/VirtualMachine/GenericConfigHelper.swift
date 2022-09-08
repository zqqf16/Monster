//
//  GenericConfigHelper.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/8.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import Virtualization

struct GenericConfigHelper: VMConfigHelper {
    var config: VMConfig
    var bundle: VMBundle
    
    init(_ config: VMConfig) {
        self.config = config
        if config.bundleURL == nil {
            config.bundleURL = VMBundle.generateBundleURL(for: config)
        }
        self.bundle = VMBundle(config.bundleURL!)
    }

    // MARK: BootLoader
    private func retrieveOrCreateEFIVariableStore() throws -> VZEFIVariableStore {
        let efiVariableStoreURL = bundle.efiVariableStoreURL
        if FileManager.default.fileExists(atPath: efiVariableStoreURL.path) {
            return VZEFIVariableStore(url: efiVariableStoreURL)
        }
        
        return try VZEFIVariableStore(creatingVariableStoreAt: efiVariableStoreURL)
    }
    
    private func createBootLoader() throws -> VZBootLoader {
        let bootloader = VZEFIBootLoader()
        bootloader.variableStore = try retrieveOrCreateEFIVariableStore()
        return bootloader
    }
    
    // MARK: Platform
    private func retrieveOrCreateMachineIdentifier() throws -> VZGenericMachineIdentifier {
        do {
            if bundle.machineIdentifierExists {
                let machineIdentifierData = try Data(contentsOf: bundle.machineIdentifierURL)
                if let machineIdentifier = VZGenericMachineIdentifier(dataRepresentation: machineIdentifierData) {
                    return machineIdentifier
                }
            }
            let machineIdentifier = VZGenericMachineIdentifier()
            try bundle.save(machineIdentifier: machineIdentifier.dataRepresentation)
            return machineIdentifier
        } catch {
            throw Failure("Failed to retrieve machine identifier: \(error.localizedDescription)")
        }
    }
    
    private func createPlatform() throws -> VZPlatformConfiguration {
        let platform = VZGenericPlatformConfiguration()
        platform.machineIdentifier = try retrieveOrCreateMachineIdentifier()
        return platform
    }
    
    // MARK: Storage
    private func createUSBMassStorageDeviceConfiguration() throws -> VZUSBMassStorageDeviceConfiguration? {
        guard config.os != .macOS,
              let restoreImageURL = config.restoreImageURL else {
            return nil
        }
        do {
            let intallerDiskAttachment = try VZDiskImageStorageDeviceAttachment(url: restoreImageURL, readOnly: true)
            return VZUSBMassStorageDeviceConfiguration(attachment: intallerDiskAttachment)
        } catch {
            throw Failure("Failed to create USB mass storage device: \(error.localizedDescription)")
        }
    }

    private func createGraphicsDeviceConfiguration() -> VZGraphicsDeviceConfiguration {
        let graphicsConfiguration = VZVirtioGraphicsDeviceConfiguration()
        graphicsConfiguration.scanouts = [
            VZVirtioGraphicsScanoutConfiguration(widthInPixels: 1280, heightInPixels: 720)
        ]
        return graphicsConfiguration
    }
    
    func createVirtualMachineConfiguration() throws -> VZVirtualMachineConfiguration {
        try bundle.prepareBundleDirectory()

        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        virtualMachineConfiguration.cpuCount = computeCPUCount()
        virtualMachineConfiguration.memorySize = computeMemorySize()
        
        let disksArray = NSMutableArray()
        
        do {
            if let usbDevice = try createUSBMassStorageDeviceConfiguration() {
                disksArray.add(usbDevice)
            }
        } catch {
            print("Create USB mass storage device failed: \(error.localizedDescription)")
        }

        disksArray.add(try createBlockDeviceConfiguration())
        guard let disks = disksArray as? [VZStorageDeviceConfiguration] else {
            fatalError("Invalid disksArray.")
        }
        
        virtualMachineConfiguration.platform = try createPlatform()
        virtualMachineConfiguration.bootLoader = try createBootLoader()
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
}
