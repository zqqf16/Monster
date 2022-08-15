//
//  VMConfig.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import Foundation
import AppKit

class VirtualMachine: Identifiable, Hashable, ObservableObject {
    enum OS: Int, CaseIterable, Identifiable {
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
}
