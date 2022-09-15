//
//  VirtualMachineView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI
import Virtualization

struct VirtualMachineView: View {
    @ObservedObject var vm: VirtualMachine

    @State var showBanner: Bool = false
    @State var currentError: Failure? = nil

    var body: some View {
        VMPlayer(vm: vm)
            .navigationTitle(vm.name)
            .toolbar {
                toolbar
            }
            .onAppear {
                if vm.state == .stopped {
                    execute(vm.run)
                }
            }
            .onReceive(vm.$state, perform: { state in
                withAnimation {
                    showBanner = state != .running
                }
            })
            .banner(isPresented: $showBanner) {
                if vm.state == .installing {
                    progressBanner
                } else {
                    textBanner
                }
            }
    }

    @ViewBuilder
    private var progressBanner: some View {
        HStack {
            ProgressView(progressMessage, value: vm.installingProgress)
        }
    }

    private var progressMessage: String {
        if vm.installingProgress < 0.1 {
            return "Installing ... (loading files)"
        }

        var progress = Int(vm.installingProgress * 100)
        progress = min(progress, 100)
        progress = max(0, progress)
        return "Installing ... (\(progress)%)"
    }

    @ViewBuilder
    private var textBanner: some View {
        HStack {
            if vm.state == .error {
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                VStack(alignment: .leading) {
                    Text(bannerTitle).fontWeight(.bold)
                    if let reason = currentError?.reason {
                        Text(reason.localizedDescription).font(.subheadline)
                    }
                }
            } else {
                Text(bannerTitle)
                    .fontWeight(.bold)
            }

            Spacer()
            Button {
                execute(vm.run)
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
        }
    }

    private var bannerTitle: String {
        if vm.state == .error {
            return currentError != nil ? currentError!.localizedDescription : "Unknow Error"
        }

        return "Virtual Machine is \(vm.state)"
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            switch vm.state {
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
            execute(vm.run)
        } label: {
            Label("Run", systemImage: "play.fill")
        }
    }

    private var pauseButton: some View {
        Button {
            execute(vm.pause)
        } label: {
            Label("Pause", systemImage: "pause.fill")
        }
    }

    private var stopButton: some View {
        Button {
            execute(vm.stop)
        } label: {
            Label("Stop", systemImage: "stop.fill")
        }
    }

    private func execute(_ function: @escaping () async throws -> Void) {
        Task {
            self.currentError = nil
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

struct VirtualMachineView_Previews: PreviewProvider {
    static var previews: some View {
        VirtualMachineView(vm: VirtualMachine(config: .defaultMacOS))
    }
}
