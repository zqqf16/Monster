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
    var id = UUID()

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
    
    enum CodingKeys: CodingKey {
        case name
        case os
        case memorySize
        case diskSize
        case cpuCount
        case restoreImagePath
        case bundlePath
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        os = try container.decode(OperatingSystem.self, forKey: .os)
        memorySize = try container.decode(StorageSize.self, forKey: .memorySize)
        diskSize = try container.decode(StorageSize.self, forKey: .diskSize)
        cpuCount = try container.decode(CpuCount.self, forKey: .cpuCount)
        restoreImagePath = try container.decode(String.self, forKey: .restoreImagePath)
        bundlePath = try container.decode(String.self, forKey: .bundlePath)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(os, forKey: .os)
        try container.encode(memorySize, forKey: .memorySize)
        try container.encode(diskSize, forKey: .diskSize)
        try container.encode(cpuCount, forKey: .cpuCount)
        try container.encode(restoreImagePath, forKey: .restoreImagePath)
        try container.encode(bundlePath, forKey: .bundlePath)
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

// MARK: Default configs

extension VMConfig {
    class var defaultMacOSConfig: VMConfig {
        VMConfig("macOS", os: .macOS, memorySize: 4.GB, diskSize: 30.GB, cpuCount: 4.core)
    }
}
