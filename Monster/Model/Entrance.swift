//
//  Entrance.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/1.
//

import Foundation
import AppKit

enum Entrance: Int, CaseIterable, Identifiable {
    
    var id: Int { self.rawValue }
    
    case macOS
    case linux
    case open
    
    var imageName: String {
        switch self {
        case .macOS: return "macOS"
        case .linux: return "Linux"
        case .open: return "arrow.down.doc"
        }
    }
    
    var image: NSImage {
        switch self {
        case .macOS: return NSImage(named: "macOS")!
        case .linux: return NSImage(named: "Linux")!
        case .open: return NSImage(systemSymbolName: "arrow.down.doc", accessibilityDescription: nil)!
        }
    }
    
    var name: String {
        switch self {
        case .open: return "Open"
        case .linux: return "Linux"
        case .macOS: return "macOS"
        }
    }
    
    var description: String {
        switch self {
        case .open: return "Open an existing virtual machine"
        case .linux: return "Install and run GUI Linux virtual machines"
        case .macOS: return "Install and run macOS virtual machines"
        }
    }
}
