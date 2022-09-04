//
//  VMConfigView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI
import Virtualization

struct VMConfigView: View {
    @ObservedObject var vmInstance: VMInstance

    var body: some View {
        VMPlayer(vm: vmInstance)
            .navigationTitle(vmInstance.config.name)
            .toolbar {
                ToolbarItemGroup(placement: .status) {
                    Button {
                        run()
                    } label: {
                        Label("Run", systemImage: "play.fill")
                    }
                    Button {
                        vmInstance.pause()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                    }
                    Button {
                        vmInstance.stop()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                    }
                }
            }
    }
    
    private func run() {
        do {
            try vmInstance.run()
        } catch {
            print(error)
        }
    }
}

struct VMConfigView_Previews: PreviewProvider {
    static var previews: some View {
        VMConfigView(vmInstance: VMInstance(.defaultMacOSConfig))
    }
}
