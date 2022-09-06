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

    @State var showBanner: Bool = false
    
    var body: some View {
        VMPlayer(vm: vmInstance)
            .navigationTitle(vmInstance.config.name)
            .toolbar {
                toolbar
            }
            .banner(isPresented: $showBanner) {
                Text("This is a banner")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                    withAnimation {
                        self.showBanner = true
                    }
                })
            }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
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
