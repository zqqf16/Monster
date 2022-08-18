//
//  VMConfigView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI
import Virtualization

struct VMConfigView: View {
    var vm: VMConfig
    
    var body: some View {
        VMPlayer(vm: VMInstance())
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

struct VMConfigView_Previews: PreviewProvider {
    static var previews: some View {
        VMConfigView(vm: VMConfig(name: "Demo", os: .macOS, memory: 4, disk: 40, cpu: 3))
    }
}
