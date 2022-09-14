//
//  VMConfigHelper.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/5.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import Virtualization

protocol VMConfigHelper {
    var config: VMConfig { get }
    var bundle: VMBundle { get }

    var needInstall: Bool { get }
    
    init(config: VMConfig, bundle: VMBundle)
    func createVirtualMachineConfiguration() throws -> VZVirtualMachineConfiguration
    
#if arch(arm64)
    func createVirtualMachineConfiguration(restoreImage: VZMacOSRestoreImage) throws -> VZVirtualMachineConfiguration
#endif
}

extension VMConfigHelper {
    var needInstall: Bool {
        return false
    }
    
#if arch(arm64)
    func createVirtualMachineConfiguration(restoreImage: VZMacOSRestoreImage) throws -> VZVirtualMachineConfiguration {
        throw Failure("MacOS is not supported on this device")
    }
#endif
}

// MARK: Common Configurations

extension VMConfigHelper {
    func computeCPUCount() -> Int {
        var cpuCount = config.cpuCount.count
        cpuCount = max(cpuCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        cpuCount = min(cpuCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        
        return cpuCount
    }
    
    func computeMemorySize() -> UInt64 {
        var memorySize = config.memorySize.bytes
        memorySize = max(memorySize, VZVirtualMachineConfiguration.minimumAllowedMemorySize)
        memorySize = min(memorySize, VZVirtualMachineConfiguration.maximumAllowedMemorySize)
        
        return memorySize
    }

    func createBlockDeviceConfiguration() throws -> VZVirtioBlockDeviceConfiguration {
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
    
    func createAudioDeviceConfiguration() -> VZVirtioSoundDeviceConfiguration {
        let audioConfiguration = VZVirtioSoundDeviceConfiguration()

        let inputStream = VZVirtioSoundDeviceInputStreamConfiguration()
        inputStream.source = VZHostAudioInputStreamSource()

        let outputStream = VZVirtioSoundDeviceOutputStreamConfiguration()
        outputStream.sink = VZHostAudioOutputStreamSink()

        audioConfiguration.streams = [inputStream, outputStream]
        return audioConfiguration
    }
    
    func createSpiceAgentConsoleDeviceConfiguration() -> VZVirtioConsoleDeviceConfiguration {
        let consoleDevice = VZVirtioConsoleDeviceConfiguration()
        
        let spiceAgentPort = VZVirtioConsolePortConfiguration()
        spiceAgentPort.name = VZSpiceAgentPortAttachment.spiceAgentPortName
        spiceAgentPort.attachment = VZSpiceAgentPortAttachment()
        consoleDevice.ports[0] = spiceAgentPort
        
        return consoleDevice
    }
    
    func createNetworkDeviceConfiguration() -> VZVirtioNetworkDeviceConfiguration {
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.attachment = VZNATNetworkDeviceAttachment()
        
        return networkDevice
    }
    
    func directorySharingConfiguration() throws -> VZDirectorySharingDeviceConfiguration {
        let tag: String = "MonsterShared"
        try VZVirtioFileSystemDeviceConfiguration.validateTag(tag)
        
        var directories: [String: VZSharedDirectory] = [:]
        config.shareFolders.forEach { folder in
            guard folder.enable else {
                return
            }
            let name = folder.url.lastPathComponent
            directories[name] = VZSharedDirectory(url: folder.url, readOnly: folder.readOnly)
        }
        
        let share = VZMultipleDirectoryShare(directories: directories)
        let device = VZVirtioFileSystemDeviceConfiguration(tag: tag)
        device.share = share
        return device
    }
}
