//
//  ConfigUtils.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/5.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

extension OperatingSystem {
    var restoreImageTitle: String {
        if self == .macOS {
            return "Restore Image"
        }
        return "ISO Image"
    }
    
    var restoreImageTips: String {
        if self == .macOS {
            return "Select a restore image file (.ipsw)"
        }
        let arch = VMConfig.arch.uppercased()
        return "Select an arch ISO image file (.iso) for \(arch)"
    }
}
