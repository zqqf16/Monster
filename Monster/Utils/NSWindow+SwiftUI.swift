//
//  NSWindow+SwiftUI.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/18.
//

import AppKit

extension NSWindow {
    var isSwiftUIWindow: Bool {
        return String(describing: type(of: self)) == "AppKitWindow"
    }
}

extension Array where Element == NSWindow {
    var swiftUIWindows: [NSWindow] {
        self.filter { $0.isSwiftUIWindow }
    }
    
    var hasSwiftUIWindow: Bool {
        swiftUIWindows.count > 0
    }
}
