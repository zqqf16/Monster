//
//  VMConfig.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import Foundation
import AppKit
import Virtualization

struct VMConfig: Codable, Hashable {
    var id = UUID().uuidString
    var name: String
    var os: OperatingSystem = .macOS
    
    var memorySize: StorageSize = 4.GB
    var diskSize: StorageSize = 30.GB
    var cpuCount: CpuCount = 4.core
    
    var restoreImageURL: URL? = nil
    var bundleURL: URL? = nil
    var shareFolders: [URL] = []
    
    var installed: Bool = false
    
    var icon: String {
        os.defaultIconName
    }
    
    // MARK: Codable
    enum CodingKeys: CodingKey {
        case id
        case name
        case os
        case memorySize
        case diskSize
        case cpuCount
        case restoreImageURL
        case bundleURL
        case shareFolders
        case installed
    }
    
    init(name: String, os: OperatingSystem = .macOS) {
        self.name = name
        self.os = os
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .name)
        name = try container.decode(String.self, forKey: .name)
        os = try container.decode(OperatingSystem.self, forKey: .os)
        
        memorySize = try container.decode(UInt64.self, forKey: .memorySize).B
        diskSize = try container.decode(UInt64.self, forKey: .diskSize).B
        cpuCount = try container.decode(Int.self, forKey: .cpuCount).core
        restoreImageURL = try? container.decodeIfPresent(URL.self, forKey: .restoreImageURL)
        bundleURL = try? container.decodeIfPresent(URL.self, forKey: .bundleURL)
        if let installed = try? container.decodeIfPresent(Bool.self, forKey: .installed) {
            self.installed = installed
        }
        if let shareFolders = try? container.decodeIfPresent([URL].self, forKey: .shareFolders) {
            self.shareFolders = shareFolders
        } else {
            self.shareFolders = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(os, forKey: .os)
        try container.encode(memorySize.bytes, forKey: .memorySize)
        try container.encode(diskSize.bytes, forKey: .diskSize)
        try container.encode(cpuCount.count, forKey: .cpuCount)
        try container.encodeIfPresent(restoreImageURL, forKey: .restoreImageURL)
        try container.encodeIfPresent(bundleURL, forKey: .bundleURL)
        try container.encode(shareFolders, forKey: .shareFolders)
        try container.encode(installed, forKey: .installed)
    }
}

// MARK: Default configs
extension VMConfig {
    static var defaultMacOS: VMConfig { .init(name: "macOS") }
    static var defaultLinux: VMConfig { VMConfig(name: "Linux", os: .linux) }
}

// MARK: Value ranges
extension VMConfig {
    static var minimumAllowedMemorySize: StorageSize {
        1.GB
    }
    
    static var maximumAllowedMemorySize: StorageSize {
        VZVirtualMachineConfiguration.maximumAllowedMemorySize.B
    }
    
    static var memorySizeRange: ClosedRange<StorageSize> {
        minimumAllowedMemorySize ... maximumAllowedMemorySize
    }
    
    static var minimumAllowedCPUCount: CpuCount {
        VZVirtualMachineConfiguration.minimumAllowedCPUCount.core
    }
    
    static var maximumAllowedCPUCount: CpuCount {
        let totalAvailableCPUs = ProcessInfo.processInfo.processorCount
        
        var virtualCPUCount = totalAvailableCPUs <= 1 ? 1 : totalAvailableCPUs
        virtualCPUCount = max(virtualCPUCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        virtualCPUCount = min(virtualCPUCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        
        return virtualCPUCount.core
    }
    
    static var cpuCountRnage: ClosedRange<CpuCount> {
        minimumAllowedCPUCount ... maximumAllowedCPUCount
    }
    
    static var minimumAllowedDiskSize: StorageSize {
        return 5.GB // 2.5GB, Ubuntu 20.04
    }
    
    static var maximumAllowedDiskSize: StorageSize {
        guard let size = FileManager.getFileSize(for: .systemFreeSize) else {
            return 100.GB
        }
        
        let sizeInGB = Double(size) / 1024 / 1024 / 1024
        if sizeInGB < 1 {
            return 10.GB // 10G, must be failed
        }
        
        return UInt64(sizeInGB).GB
    }
    
    static var diskSizeRange: ClosedRange<StorageSize> {
        minimumAllowedDiskSize ... maximumAllowedDiskSize
    }
}
