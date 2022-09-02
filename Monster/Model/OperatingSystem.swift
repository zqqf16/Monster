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
