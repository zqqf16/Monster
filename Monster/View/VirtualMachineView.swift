//
//  VirtualMachineView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI

struct VirtualMachineView: View {
    var vm: VirtualMachine
    
    var body: some View {
        Text("Run \(vm.name)")
            .toolbar {
                Toolbar()
            }
            .presentedWindowToolbarStyle(.unifiedCompact)
            .navigationTitle(vm.name)
    }
}

private struct Toolbar: ToolbarContent {
    @Environment(\.openWindow) private var openWindow

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            Button {
                openWindow(value: "run")
            } label: {
                Label("Run", systemImage: "play.fill")
            }
            Button {
                //
            } label: {
                Label("Pause", systemImage: "pause.fill")
            }
            Button {
                //
            } label: {
                Label("Stop", systemImage: "stop.fill")
            }
        }
        ToolbarItem() {
            Spacer()
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                //
            } label: {
                Label("Create a new VM", systemImage: "plus")
            }
        }
    }
}

struct VirtualMachineView_Previews: PreviewProvider {
    static var previews: some View {
        VirtualMachineView(vm: VirtualMachine(name: "Demo", os: .macOS, memory: 4, disk: 40, cpu: 3))
    }
}
