//
//  MonsterApp.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI

@main
struct MonsterApp: App {
    
    @StateObject private var store = Store()
    
    var body: some Scene {
        // Main window
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
            }
        }
        
        // Preview
        WindowGroup(for: String.self) { vmID in
            VirtualMachineView()
                .navigationTitle("Preview")
                .environmentObject(store)
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
        }
        .windowToolbarStyle(.unifiedCompact)

        // Menu bar
        MenuBarExtra("Monster", systemImage: "desktopcomputer") {
            Button {
                //
            } label: {
                Text("Hello Monster")
            }
        }
    }
}
