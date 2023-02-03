//
//  MonsterApp.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import AppKit
import SwiftUI
import Combine

extension NSApplication: NSWindowDelegate {
    func setDockIconHidden(_ isHidden: Bool) {
        if !isHidden {
            self.setActivationPolicy(.regular)
            return
        }

        self.setActivationPolicy(.accessory)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var subscriptions = Set<AnyCancellable>()
    private var timer: Timer?

    func applicationDidFinishLaunching(_: Notification) {
        // disable tabbing
        NSWindow.allowsAutomaticWindowTabbing = false

        let preview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        if preview != "1" {
            // Do not active app during xcode previewing
            NSApp.activate(ignoringOtherApps: true)
        }
        
        NSApp.setDockIconHidden(!AppSettings.standard.showDockIcon)
        AppSettings.standard.settingsChangedSubject.filter {
            $0 == \AppSettings.showDockIcon
        }.sink {_ in
            self.updateDockIconVisible()
        }.store(in: &subscriptions)
    }
    
    private func updateDockIconVisible() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            NSApp.setDockIconHidden(!AppSettings.standard.showDockIcon)
        })
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
        
        // Preference
        Settings {
            SettingsView()
        }
        
        // Menu bar item
        MenuBarExtra("Monster", image: "StatusBarIcon") {
            MenuBar()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.window)
    }

    private func open(url: URL) {
        print("Open url: \(url.path)")
        guard url.isFileURL else {
            return
        }

        let _ = try? store.importVirtualMachine(from: url)
    }
}
