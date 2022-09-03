//
//  OperatingSystem.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//

import Foundation

enum OperatingSystem: Int, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case macOS
    case ubuntu
    case debian
    case fedora
    case linux
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
