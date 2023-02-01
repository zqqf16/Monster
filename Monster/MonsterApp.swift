//
//  MonsterApp.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_: Notification) {
        // disable tabbing
        NSWindow.allowsAutomaticWindowTabbing = false

        createStatusItem()

        let preview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        if preview != "1" {
            // Do not active app during xcode previewing
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func createStatusItem() {
        // waiting for MenuBarExtra ...
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
                .onOpenURL { url in
                    open(url: url)
                }
                .environmentObject(store)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
        }

        // Preview
        WindowGroup(for: String.self) { $vmID in
            if let vmID = $vmID.wrappedValue, let vm = store.virtualMachine(with: vmID) {
                VirtualMachineView(vm: vm)
                    .environmentObject(store)
            }
        }
        .defaultSize(width: 1280, height: 720)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
        }
        .windowToolbarStyle(.unifiedCompact)
    }

    private func open(url: URL) {
        print("Open url: \(url.path)")
        guard url.isFileURL else {
            return
        }

        let _ = try? store.importVirtualMachine(from: url)
    }
}
