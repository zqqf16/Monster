//
//  SnapshotView.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/9.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct SnapshotView: View {
    @ObservedObject var vm: VirtualMachine
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let snapshot = vm.snapshot {
                    Image(nsImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.1))
                }
            }

            buttons
                .offset(y: -4)
        }
        .cornerRadius(8)
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(height: 120)
    }

    @ViewBuilder
    private var buttons: some View {
        HStack {
            switch vm.state {
            case .running:
                pauseButton
                stopButton
            case .paused:
                resumeButton
                stopButton
            default:
                runButton
            }
            Spacer()
            previewButton
        }
        .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
        // .background(.gray.opacity(0.5))
        .cornerRadius(4)
    }

    @ViewBuilder
    private func createButton(_ image: String, action: @escaping () async throws -> Void) -> some View {
        Button {
            Task {
                try? await action()
            }
        } label: {
            Image(systemName: image).foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .shadow(color: .gray, radius: 4)
    }

    private var runButton: some View {
        createButton("play.fill") {
            try await vm.run()
            openWindow(value: vm.id)
        }
    }

    private var pauseButton: some View {
        createButton("pause.fill", action: vm.pause)
    }

    private var stopButton: some View {
        createButton("stop.fill", action: vm.stop)
    }

    private var resumeButton: some View {
        createButton("arrow.clockwise", action: vm.run)
    }

    private var previewButton: some View {
        createButton("display") {
            openWindow(value: vm.id)
        }
    }
}

struct SnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotView(vm: VirtualMachine(config: .defaultMacOS))
    }
}
