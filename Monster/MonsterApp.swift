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
        
        let preview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        if preview != "1" {
            NSApp.activate(ignoringOtherApps: true)
        }
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
        if !NSApp.windows.hasSwiftUIWindow {
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
                .handlesExternalEvents(preferring: Set(arrayLiteral: "main"), allowing: Set(arrayLiteral: "*"))
                .onOpenURL { (url) in
                    if url.isFileURL {
                        print("Open file: \(url.path)")
                    }
                }
                .environmentObject(store)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
            }
        }
        
        // Preview
        WindowGroup(for: VMConfig.self) { $vm in
            if let _ = $vm.wrappedValue {
                VMConfigView(vmInstance: VMInstance())
                    .navigationTitle("Preview")
                    .environmentObject(store)
                    .task {
                        try? await Task.sleep(nanoseconds: 1 * 1000)
                        disableWindowRestoration()
                    }
            }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
        }
        .windowToolbarStyle(.unifiedCompact)
    }
    
    private func disableWindowRestoration() {
        NSApp.windows.swiftUIWindows.forEach { window in
            debugPrint("Window:\(window.title) disable restoration")
            window.isRestorable = false
        }
    }
}
