//
//  MonsterApp.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // disable tabbing
        NSWindow.allowsAutomaticWindowTabbing = false
        createStatusItem()
    }
        
    private func createStatusItem() {
        // waitting for MenuBarExtra ...
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let statusButton = statusItem?.button
        statusButton?.image = NSImage(systemSymbolName: "m.square.fill", accessibilityDescription: nil)
        statusButton?.image = NSImage(named: "StatusBarIcon")
        statusButton?.action = #selector(AppDelegate.showWindow)
    }
    
    @objc func showWindow() {
        debugPrint("show window")
        if !NSApp.windows.contains(where: { window in
            /*
             ▿ 3 elements
               - 0 : <NSStatusBarWindow: 0x156686b50>
               ▿ 1 : <SwiftUI.AppKitWindow: 0x156747450>
               - 2 : <NSMenuWindowManagerWindow: 0x15666dd90>
             */
            String(describing: type(of: window)) == "AppKitWindow"
        }) {
            debugPrint("Create a new window")
            NSWorkspace.shared.open(URL(string: "monster://main")!)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct MonsterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var store = Store()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // Main window
        WindowGroup("Monster", id: "Main") {
            ContentView()
                .environmentObject(store)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
            }
        }
        
        // Preview
        WindowGroup(for: VMConfig.self) { $vm in
            if let vm = $vm.wrappedValue {
                VMConfigView(vm: vm)
                    .navigationTitle("Preview")
                    .environmentObject(store)
            }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}
