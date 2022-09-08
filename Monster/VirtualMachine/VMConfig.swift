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
    
    @Published var restoreImageURL: URL?
    @Published var bundleURL: URL?
    
    @Published var shareFolders: [URL] = []
    
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
        restoreImageURL: URL? = nil,
        bundleURL: URL? = nil
    ) {
        self.name = name
        self.os = os
        self.memorySize = memorySize
        self.diskSize = diskSize
        self.cpuCount = cpuCount
        self.restoreImageURL = restoreImageURL
        self.bundleURL = bundleURL
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
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        os = try container.decode(OperatingSystem.self, forKey: .os)
        
        memorySize = try container.decode(UInt64.self, forKey: .memorySize).B
        diskSize = try container.decode(UInt64.self, forKey: .diskSize).B
        cpuCount = try container.decode(Int.self, forKey: .cpuCount).core
        restoreImageURL = try? container.decodeIfPresent(URL.self, forKey: .restoreImageURL)
        bundleURL = try? container.decodeIfPresent(URL.self, forKey: .bundleURL)
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
    }
}


// MARK: System limitation

extension VMConfig {
    class var minimumAllowedMemorySize: StorageSize {
        1.GB
    }
    
    class var maximumAllowedMemorySize: StorageSize {
        VZVirtualMachineConfiguration.maximumAllowedMemorySize.B
    }
    
    class var memorySizeRange: ClosedRange<StorageSize> {
        minimumAllowedMemorySize ... maximumAllowedMemorySize
    }
    
    class var minimumAllowedCPUCount: CpuCount {
        VZVirtualMachineConfiguration.minimumAllowedCPUCount.core
    }
    
    class var maximumAllowedCPUCount: CpuCount {
        let totalAvailableCPUs = ProcessInfo.processInfo.processorCount
        
        var virtualCPUCount = totalAvailableCPUs <= 1 ? 1 : totalAvailableCPUs
        virtualCPUCount = max(virtualCPUCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        virtualCPUCount = min(virtualCPUCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        
        return virtualCPUCount.core
    }
    
    class var cpuCountRnage: ClosedRange<CpuCount> {
        minimumAllowedCPUCount ... maximumAllowedCPUCount
    }
    
    class var minimumAllowedDiskSize: StorageSize {
        return 5.GB // 2.5GB, Ubuntu 20.04
    }
    
    class var maximumAllowedDiskSize: StorageSize {
        guard let size = FileManager.getFileSize(for: .systemFreeSize) else {
            return 100.GB
        }
        
        let sizeInGB = Double(size) / 1024 / 1024 / 1024
        if sizeInGB < 1 {
            return 10.GB // 10G, must be failed
        }
        
        return UInt64(sizeInGB).GB
    }
    
    class var diskSizeRange: ClosedRange<StorageSize> {
        minimumAllowedDiskSize ... maximumAllowedDiskSize
    }
}

// MARK: Default configs

extension VMConfig {
    class var defaultMacOSConfig: VMConfig {
        VMConfig("macOS", os: .macOS, memorySize: 4.GB, diskSize: 30.GB, cpuCount: 4.core)
    }
}
