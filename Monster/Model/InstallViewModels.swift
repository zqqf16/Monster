//
//  InstallModels.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import AppKit

enum Entrance: Int, CaseIterable, Identifiable {
    
    var id: Int { self.rawValue }
    
    case macOS
    case linux
    case `import`
    
    var imageName: String {
        switch self {
        case .macOS: return "macOS"
        case .linux: return "Linux"
        case .import: return "arrow.down.doc"
        }
    }
    
    var image: NSImage {
        switch self {
        case .macOS: return NSImage(named: "macOS")!
        case .linux: return NSImage(named: "Linux")!
        case .import: return NSImage(systemSymbolName: "arrow.down.doc", accessibilityDescription: nil)!
        }
    }
    
    var name: String {
        switch self {
        case .import: return "Import"
        case .linux: return "Linux"
        case .macOS: return "macOS"
        }
    }
    
    var restoreImageName: String {
        switch self {
        case .import: return ""
        case .linux: return "ISO Image"
        case .macOS: return "Restore Image"
        }
    }
    
    var description: String {
        switch self {
        case .import: return "Import an existing virtual machine"
        case .linux: return "Install and run GUI Linux virtual machine"
        case .macOS: return "Install and run macOS virtual machine"
        }
    }
}
