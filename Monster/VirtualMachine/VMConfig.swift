//
//  VMConfig.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import Foundation
import AppKit
import Virtualization

class VMConfig: ObservableObject, Identifiable, Hashable, Codable {
    var id = UUID().uuidString

    @Published var name: String
    @Published var os: OperatingSystem = .macOS
    
    @Published var memorySize: StorageSize
    @Published var diskSize: StorageSize
    @Published var cpuCount: CpuCount
    
    @Published var restoreImagePath: String?
    @Published var bundlePath: String?
    
    @Published var enableKeyboard = true
    @Published var enableNetwork = true
    @Published var enableAudio = true
    @Published var enableConsole = true
    
    var machineIdentifierData: Data?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: VMConfig, rhs: VMConfig) -> Bool {
        return lhs.id == rhs.id
    }

    var icon: String {
        os.defaultIconName
    }
    
    init(
        _ name: String,
        os: OperatingSystem,
        memorySize: StorageSize,
        diskSize: StorageSize,
        cpuCount: CpuCount,
        restoreImage: String? = nil,
        bundlePath: String? = nil
    ) {
        self.name = name
        self.os = os
        self.memorySize = memorySize
        self.diskSize = diskSize
        self.cpuCount = cpuCount
        self.restoreImagePath = restoreImage
        self.bundlePath = bundlePath
    }
    
    // MARK: Codable
    enum CodingKeys: CodingKey {
        case id
        case name
        case os
        case memorySize
        case diskSize
        case cpuCount
        case restoreImagePath
        case bundlePath
        case machineIdentifierData
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        os = try container.decode(OperatingSystem.self, forKey: .os)
        
        memorySize = try container.decode(UInt64.self, forKey: .memorySize).B
        diskSize = try container.decode(UInt64.self, forKey: .diskSize).B
        cpuCount = try container.decode(Int.self, forKey: .cpuCount).core
        restoreImagePath = try? container.decodeIfPresent(String.self, forKey: .restoreImagePath)
        bundlePath = try? container.decodeIfPresent(String.self, forKey: .bundlePath)
        machineIdentifierData = try? container.decodeIfPresent(Data.self, forKey: .machineIdentifierData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(os, forKey: .os)
        try container.encode(memorySize.bytes, forKey: .memorySize)
        try container.encode(diskSize.bytes, forKey: .diskSize)
        try container.encode(cpuCount.count, forKey: .cpuCount)
        try container.encodeIfPresent(restoreImagePath, forKey: .restoreImagePath)
        try container.encodeIfPresent(bundlePath, forKey: .bundlePath)
        try container.encodeIfPresent(machineIdentifierData, forKey: .machineIdentifierData)
    }
}


// MARK: System limitation

extension VMConfig {
    class var minimumAllowedMemorySize: UInt64 {
        1024 * 1024 * 1024 // 1G
    }
    
    class var maximumAllowedMemorySize: UInt64 {
        VZVirtualMachineConfiguration.maximumAllowedMemorySize
    }
    
    class var minimumAllowedCPUCount: Int {
        VZVirtualMachineConfiguration.minimumAllowedCPUCount
    }
    
    class var maximumAllowedCPUCount: Int {
        let totalAvailableCPUs = ProcessInfo.processInfo.processorCount
        
        var virtualCPUCount = totalAvailableCPUs <= 1 ? 1 : totalAvailableCPUs - 1
        virtualCPUCount = max(virtualCPUCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        virtualCPUCount = min(virtualCPUCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        
        return virtualCPUCount
    }
    
    class var minimumAllowedDiskSize: UInt64 {
        return 5 * 1024 * 1024 * 1024 // 2.5GB, Ubuntu 20.04
    }
    
    class var maximumAllowedDiskSize: UInt64 {
        guard let size = FileManager.getFileSize(for: .systemFreeSize) else {
            return 100 * 1024 * 1024 * 1024 // 100G
        }
        
        let sizeInGB = Double(size) / 1024 / 1024 / 1024
        if sizeInGB < 1 {
            return 10 * 1024 * 1024 * 1024 // 10G, must be failed
        }
        
        return UInt64(sizeInGB) * 1024 * 1024 * 1024
    }
}

// MARK: VZVirtualMachineConfiguration

extension VMConfig {
    
    private func computeCPUCount() -> Int {
        var cpuCount = cpuCount.count
        cpuCount = max(cpuCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        cpuCount = min(cpuCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        
        return cpuCount
    }

    private func computeMemorySize() -> UInt64 {
        var memorySize = memorySize.bytes
        memorySize = max(memorySize, VZVirtualMachineConfiguration.minimumAllowedMemorySize)
        memorySize = min(memorySize, VZVirtualMachineConfiguration.maximumAllowedMemorySize)
        
        return memorySize
    }
    
    private func retrieveMachineIdentifier() -> VZGenericMachineIdentifier {
        if let machineIdentifierData = machineIdentifierData,
           let machineIdentifier = VZGenericMachineIdentifier(dataRepresentation: machineIdentifierData) {
            return machineIdentifier
        }
        
        let machineIdentifier = VZGenericMachineIdentifier()
        self.machineIdentifierData = machineIdentifier.dataRepresentation
        return machineIdentifier
    }

    private func retrieveEFIVariableStore(_ bundle: VMBundle) throws -> VZEFIVariableStore {
        let efiVariableStoreURL = bundle.efiVariableStoreURL
        if FileManager.default.fileExists(atPath: efiVariableStoreURL.path) {
            return VZEFIVariableStore(url: efiVariableStoreURL)
        }
        
        return try VZEFIVariableStore(creatingVariableStoreAt: efiVariableStoreURL)
    }
    
    private func createUSBMassStorageDeviceConfiguration() throws -> VZUSBMassStorageDeviceConfiguration {
        guard let restoreImagePath = self.restoreImagePath else {
            throw VMError.restoreImageNotFound
        }
        let restoreImageURL = URL(filePath: restoreImagePath)
        let intallerDiskAttachment = try VZDiskImageStorageDeviceAttachment(url: restoreImageURL, readOnly: true)
        return VZUSBMassStorageDeviceConfiguration(attachment: intallerDiskAttachment)
    }
    
    private func createMainDiskImage(_ bundle: VMBundle) throws {
        let mainDiskImagePath = bundle.diskImageURL.path
        let diskCreated = FileManager.default.createFile(atPath: mainDiskImagePath, contents: nil, attributes: nil)
        if !diskCreated {
            throw VMError.fileCreationFailed(mainDiskImagePath)
        }
        
        let mainDiskFileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: mainDiskImagePath))
        try mainDiskFileHandle.truncate(atOffset: diskSize.bytes)
    }

    
    private func createBlockDeviceConfiguration(_ bundle: VMBundle) throws -> VZVirtioBlockDeviceConfiguration {
        let path = bundle.diskImageURL.path
        if !FileManager.default.fileExists(atPath: path) {
            try createMainDiskImage(bundle)
        }
        
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

    func createVirtualMachineConfiguration() throws -> VZVirtualMachineConfiguration {
        guard let bundlePath = self.bundlePath else {
            throw VMError.bundleNotFound
        }
        
        let bundle = VMBundle(URL(filePath: bundlePath))
        let needInstall = bundle.needInstall
        
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()

        virtualMachineConfiguration.cpuCount = computeCPUCount()
        virtualMachineConfiguration.memorySize = computeMemorySize()
        
        let platform = VZGenericPlatformConfiguration()
        platform.machineIdentifier = retrieveMachineIdentifier()
        
        let bootloader = VZEFIBootLoader()
        bootloader.variableStore = try retrieveEFIVariableStore(bundle)
        
        let disksArray = NSMutableArray()
        if needInstall {
            disksArray.add(try createUSBMassStorageDeviceConfiguration())
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
        try bundle.save(config: self)

        return virtualMachineConfiguration
    }
}

// MARK: Default configs

extension VMConfig {
    class var defaultMacOSConfig: VMConfig {
        VMConfig("macOS", os: .macOS, memorySize: 4.GB, diskSize: 30.GB, cpuCount: 4.core)
    }
}
