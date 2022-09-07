//
//  VMConfigView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI
import Virtualization

struct VMConfigView: View {
    @ObservedObject var instance: VMInstance

    @State var showBanner: Bool = false
    
    var body: some View {
        VMPlayer(instance: instance)
            .navigationTitle(instance.config.name)
            .toolbar {
                toolbar
            }
            .onAppear {
                //
            }
            .onReceive(instance.$state, perform: { state in
                withAnimation {
                    showBanner = state != .running
                }
            })
            .banner(isPresented: $showBanner) {
                if instance.state == .installing {
                    progressBanner
                } else {
                    textBanner
                }
            }
        }

    @ViewBuilder
    private var progressBanner: some View {
        HStack {
            ProgressView("Installing...", value: instance.installingProgress)
        }
    }
    
    @ViewBuilder
    private var textBanner: some View {
        HStack {
            if instance.state == .error {
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
            }
            Text(bannerMessage)
                .fontWeight(.bold)
            Spacer()
            Button {
                run()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
        }
    }
    
    private var bannerMessage: String {
        switch instance.state {
        case .error:
            return instance.currentError != nil ? instance.currentError!.localizedDescription : "Unknow Error!"
        default:
            return "Virtual Machine is \(instance.state)"
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
                instance.pause()
            } label: {
                Label("Pause", systemImage: "pause.fill")
            }
            Button {
                instance.stop()
            } label: {
                Label("Stop", systemImage: "stop.fill")
            }
        }
    }

    private func run() {
        do {
            try instance.run()
        } catch {
            print(error)
        }
    }
}

struct VMConfigView_Previews: PreviewProvider {
    static var previews: some View {
        VMConfigView(instance: VMInstance(.defaultMacOSConfig))
    }
}
