//
//  GuideView.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//

import SwiftUI

struct InstallView: View {
    @ObservedObject var config = VMConfig("Ubuntu 20.04", os: .ubuntu, memorySize: 8.GB, diskSize: 30.GB, cpuCount: 4.core)

    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    @State var linuxDictribution: OperatingSystem?
    
    var body: some View {
        VStack {
            Spacer()
            Text("New Virtual Machine")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            HStack {
                ForEach(Entrance.allCases) { entrance in
                    EntranceItem(
                        selection: currentEntrance,
                        entrance: entrance)
                }
            }
            
            Spacer(minLength: 20)
            grid
            Spacer()
            footer
            Spacer()
        }
        .scenePadding()
        .background(.background)
        .frame(minWidth: 600)
    }
    
    private var currentEntrance: Binding<Entrance?> {
        Binding(
            get: {
                switch config.os {
                case .macOS: return Entrance.macOS
                default: return Entrance.linux
                }
            },
            set: { value in
                withAnimation {
                    switch value {
                    case .macOS:
                        linuxDictribution = config.os
                        config.os = .macOS
                    case .linux: config.os = linuxDictribution ?? .linux
                    case .import:
                        // do something
                        break
                    case .none:
                        break
                    }
                }
            }
        )
    }
    
    @ViewBuilder
    private var grid: some View {
        Grid(alignment: .leading, horizontalSpacing: 10) {
            generalRows
            Divider()
            systemRows
            Divider()
            advancedRows
            Divider()
        }
    }
    
    private var distributionRow: some View {
        BaseGridRow("Linux Distribution") {
            HStack {
                Picker("", selection: $config.os) {
                    ForEach(OperatingSystem.linuxDistributions) { os in
                        Text(os.name).font(.subheadline).tag(os)
                    }
                }
                .labelsHidden()
                .frame(width: 80)
                Image(config.os.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
        }
    }
    
    private var restoreImageRow: some View {
        let comment: String
        let title: String
        if config.os == .macOS {
            title = "Restore Image"
            comment = "Select a restore image file (.ipsw)"
        } else {
            title = "ISO Image"
            comment = "Select an ISO image file (.iso)"
        }

        let hasRestoreImage = config.restoreImagePath != nil
        return BaseGridRow(title) {
            HStack {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK {
                        config.restoreImagePath = panel.url?.relativePath
                    }
                } label: {
                    Image(systemName: "folder.badge.plus")
                }.buttonStyle(.plain)
                if hasRestoreImage {
                    Text(config.restoreImagePath!)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .font(.subheadline)
                } else {
                    Text(comment)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .font(.subheadline)
                        .italic()
                }
            }
        }
    }
    
    @ViewBuilder
    private var generalRows: some View {
        if currentEntrance.wrappedValue == .linux {
            distributionRow
        }
        restoreImageRow
        BaseGridRow("Name") {
            TextField("", text: $config.name)
                .font(.subheadline)
                .frame(minWidth: 240)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    @ViewBuilder
    private var systemRows: some View {
        BaseGridRow("Memory") {
            UnitSlider(
                value: $config.memorySize,
                range: VMConfig.minimumAllowedMemorySize.B ... VMConfig.maximumAllowedMemorySize.B,
                step: 1.GB,
                units: [.mebibytes, .gibibytes]
            )
        }
        BaseGridRow("Disk Size") {
            UnitSlider(
                value: $config.diskSize,
                range: VMConfig.minimumAllowedDiskSize.B ... VMConfig.maximumAllowedDiskSize.B,
                step: 10.GB,
                units: [.mebibytes, .gibibytes]
            )
        }
        BaseGridRow("CPU Count") {
            UnitSlider(
                value: $config.cpuCount,
                range: VMConfig.minimumAllowedCPUCount.core ... VMConfig.maximumAllowedCPUCount.core,
                step: 1.core,
                units: []
            )
        }
    }
    
    @ViewBuilder
    private var advancedRows: some View {
        BaseGridRow("Advanced") {
            Toggle("Keyboard", isOn: $config.enableKeyboard).font(.subheadline)
        }
        toggleRow("Audio", isOn: $config.enableAudio)
        toggleRow("Network", isOn: $config.enableNetwork)
        toggleRow("Console", isOn: $config.enableConsole)
    }
    
    func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        GridRow {
            Spacer()
            Toggle(title, isOn: isOn).font(.subheadline)
        }
    }
    
    @ViewBuilder
    private var footer: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            .keyboardShortcut(.cancelAction)
            Spacer()
            Button {
                commit()
            } label: {
                Text("Next")
            }
            .keyboardShortcut(.defaultAction)
        }
    }
    
    private func commit() {
        store.createVirtualMachine(with: config)
        dismiss()
    }
}

private struct BaseGridRow<Content> : View where Content : View {
    var title: String = ""
    
    @ViewBuilder var contentBilder: () -> Content
    
    init(_ title: String = "", contentBuilder: @escaping () -> Content) {
        self.title = title
        self.contentBilder = contentBuilder
    }
    
    var body: some View {
        GridRow {
            Text(title)
                .frame(minWidth: 120, alignment: .leading)
                .gridColumnAlignment(.leading)
            contentBilder()
                .gridColumnAlignment(.leading)
        }.frame(minHeight: 20)
    }
}

struct InstallView_Previews: PreviewProvider {
    static var previews: some View {
        InstallView()
    }
}
