//
//  MenuBar.swift
//  Monster
//
//  Created by zqqf16 on 2023/2/3.
//  Copyright © 2023 zqqf16. All rights reserved.
//

import SwiftUI

struct ConfigInfoView: View {
    @ObservedObject var vm: VirtualMachine

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Circle()
                .fill(Color(nsColor: vm.state.color))
                .frame(width: 8)
            
            Spacer(minLength: 6)

            Text("\(vm.config.diskSize.gb)")
                .font(.system(.body, design: .monospaced))
            Text("G DISK")
                .foregroundColor(.primary.opacity(0.7))
                .font(.subheadline)
            
            Spacer(minLength: 4)
            
            Text("\(vm.config.memorySize.mb)")
                .font(.system(.body, design: .monospaced))
            Text("M MEM")
                .foregroundColor(.primary.opacity(0.7))
                .font(.subheadline)
            
            Spacer(minLength: 4)
            
            Text("\(vm.config.cpuCount.count)")
                .font(.system(.body, design: .monospaced))
            Text("CPU")
                .foregroundColor(.primary.opacity(0.7))
                .font(.subheadline)
        }
    }
}

struct MenuItem: View {
    @ObservedObject var vm: VirtualMachine
    @Environment(\.openWindow) private var openWindow
    
    @State var isHovering = false
    
    var body: some View {
        GroupBox {
            HStack(spacing: 8) {
                iconView
                    .frame(width: 48, height: 48)
                descriptionView
                    .frame(maxWidth: .infinity, alignment: .leading)
                previewButton
                    .frame(width: 36)
            }
        }
        .onHover { onHover in
            withAnimation {
                isHovering = onHover
            }
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
    }
    
    @ViewBuilder
    private var iconView: some View {
        ZStack(alignment: .center) {
            if let snapshot = vm.snapshot {
                Image(nsImage: snapshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(vm.config.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }.cornerRadius(4)
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(vm.name)
                .font(.title2)
            ConfigInfoView(vm: vm)
        }
    }
    
    @ViewBuilder
    private var previewButton: some View {
        Button {
            NSApp.closeMenuBarExtraWindow()
            openWindow(value: vm.id)
            NSApp.activate(ignoringOtherApps: true)
        } label: {
            Image(systemName: "display")
        }
        .buttonStyle(.plain)
    }
}

struct MenuBar: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        VStack {
            ForEach(store.vms) { vm in
                MenuItem(vm: vm)
                    .onTapGesture {
                        store.selectedVM = vm
                        showMainWindow()
                    }
                    .frame(maxWidth: .infinity)
            }
            Divider()
            Button {
                showMainWindow()
            } label: {
                Text("Show window")
            }
            .buttonStyle(.borderless)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(12)
    }
    
    func showMainWindow() {
        NSApp.closeMenuBarExtraWindow()
        NSApp.showMainWindow()
    }
}

struct MenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MenuBar()
    }
}
