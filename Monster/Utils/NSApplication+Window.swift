//
//  NSApplication+Window.swift
//  Monster
//
//  Created by zqqf16 on 2023/2/3.
//  Copyright © 2023 zqqf16. All rights reserved.
//

import Cocoa

extension NSApplication {
    func closeMenuBarExtraWindow() {
        windows.forEach { window in
            if window.isExcludedFromWindowsMenu {
                window.close()
            }
        }
    }
    
    func showMainWindow() {
        self.closeMenuBarExtraWindow()
        NSWorkspace.shared.open(URL(string: "monster://main")!)
    }
}
