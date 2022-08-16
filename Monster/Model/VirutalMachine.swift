//
//  VMConfig.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import Foundation
import AppKit

class VirtualMachine: ObservableObject, Identifiable, Hashable, Codable {
    enum OS: Int, CaseIterable, Identifiable, Codable {
        var id: Self { self }
        
        case macOS
        case linux
        case ubuntu
        case debian
        case fedora
        
        var name: String {
            switch self {
            case .macOS: return "macOS"
            case .linux: return "Linux"
            case .fedora: return "Fedora"
            case .ubuntu: return "Ubuntu"
            case .debian: return "Debian"
            }
        }
        
        var defaultIconName: String { name }
    }
    
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: VirtualMachine, rhs: VirtualMachine) -> Bool {
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
