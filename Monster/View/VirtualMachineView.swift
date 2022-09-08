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
    @State var currentError: Failure? = nil

    var body: some View {
        VMPlayer(instance: instance)
            .navigationTitle(instance.config.name)
            .toolbar {
                toolbar
            }
            .onAppear {
                if instance.state == .stopped {
                    execute(instance.run)
                }
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
            ProgressView(progressMessage, value: instance.installingProgress)
        }
    }
    
    private var progressMessage: String {
        if instance.installingProgress < 0.1 {
            return "Installing ... (loading files)"
        }
        
        var progress = Int(instance.installingProgress * 100)
        progress = min(progress, 100)
        progress = max(0, progress)
        return "Installing ... (\(progress)%)"
    }
    
    @ViewBuilder
    private var textBanner: some View {
        HStack {
            if instance.state == .error {
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                VStack(alignment: .leading) {
                    if let error = instance.currentError {
                        Text(error.localizedDescription).fontWeight(.bold)
                    } else {
                        Text("Unknow Error")
                    }
                    
                    if let reason = instance.currentError?.reason {
                        Text(reason.localizedDescription).font(.subheadline)
                    }
                }
            } else {
                Text(bannerMessage)
                    .fontWeight(.bold)
            }
            
            Spacer()
            Button {
                execute(instance.run)
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
        ToolbarItemGroup(placement: .navigation) {
            switch instance.state {
            case .running:
                pauseButton
                stopButton
            case .paused:
                runButton
                stopButton
            default:
                runButton
            }
        }
    }
    
    private var runButton: some View {
        Button {
            execute(instance.run)
        } label: {
            Label("Run", systemImage: "play.fill")
        }
    }
    
    private var pauseButton: some View {
        Button {
            execute(instance.pause)
        } label: {
            Label("Pause", systemImage: "pause.fill")
        }
    }
    
    private var stopButton: some View {
        Button {
            execute(instance.stop)
        } label: {
            Label("Stop", systemImage: "stop.fill")
        }
    }
    
    private func execute(_ function: @escaping () async throws -> Void) {
        Task {
            do {
                try await function()
            } catch {
                if let error = error as? Failure {
                    self.currentError = error
                } else {
                    self.currentError = Failure("Unknow error", reason: error)
                }
                withAnimation {
                    self.showBanner = true
                }
            }
        }
    }
}

struct VMConfigView_Previews: PreviewProvider {
    static var previews: some View {
        VMConfigView(instance: VMInstance(.defaultMacOSConfig))
    }
}
