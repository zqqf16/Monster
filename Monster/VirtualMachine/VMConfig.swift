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
    enum OS: Int, CaseIterable, Identifiable, Codable {
        var id: Self { self }
        
        case macOS
        case linux
        case ubuntu
        case debian
        case fedora
        case arch
        case redhat
        
        var name: String {
            switch self {
            case .macOS: return "macOS"
            case .linux: return "Linux"
            case .fedora: return "Fedora"
            case .ubuntu: return "Ubuntu"
            case .debian: return "Debian"
            case .arch: return "Arch"
            case .redhat: return "RedHat"
            }
        }
        
        var defaultIconName: String { name }
    }
    
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: VMConfig, rhs: VMConfig) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var name: String = "macOS VM"
    @Published var os: OS = .macOS
    var icon: String {
        os.defaultIconName
    }
    
    @Published var memory: Int
    @Published var disk: Int
    @Published var cpu: Int
    
    @Published var iso: String?
    @Published var path: String?
    
    init(id: UUID = UUID(), name: String, os: OS, memory: Int, disk: Int, cpu: Int, iso: String? = nil, path: String? = nil) {
        self.id = id
        self.name = name
        self.os = os
        self.memory = memory
        self.disk = disk
        self.cpu = cpu
        self.iso = iso
        self.path = path
    }
    
    enum CodingKeys: CodingKey {
        case name
        case os
        case memory
        case disk
        case cpu
        case iso
        case path
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        os = try container.decode(OS.self, forKey: .os)
        memory = try container.decode(Int.self, forKey: .memory)
        disk = try container.decode(Int.self, forKey: .disk)
        cpu = try container.decode(Int.self, forKey: .cpu)
        iso = try container.decode(String.self, forKey: .iso)
        path = try container.decode(String.self, forKey: .path)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(os, forKey: .os)
        try container.encode(memory, forKey: .memory)
        try container.encode(disk, forKey: .disk)
        try container.encode(cpu, forKey: .cpu)
        try container.encode(iso, forKey: .iso)
        try container.encode(path, forKey: .path)
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
