//
//  GuideView.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//

import SwiftUI

struct InstallView: View {
    @State private var entrance: Entrance? = .macOS

    @State private var restoreImagePath: String?
    @State private var name: String = "New Virtual Machine"
    @State private var memorySize = 4.GB
    @State private var diskSize = 20.GB
    @State private var cpuCount = 4.core
    
    @State private var enableKeyboard = true
    @State private var enableNetwork = true
    @State private var enableAudio = true
    @State private var enableConsole = true
    
    @Environment(\.dismiss) private var dismiss

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
                        selection: $entrance,
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
    
    @ViewBuilder
    private var generalRows: some View {
        BaseGridRow("Restore Image") {
            HStack {
                if let path = restoreImagePath, path.count > 0 {
                    Text(path)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .font(.subheadline)
                }
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK {
                        self.restoreImagePath = panel.url?.relativePath
                    }
                } label: {
                    Image(systemName: "folder.badge.plus")
                }.buttonStyle(.plain)
            }
        }
        
        BaseGridRow("Name") {
            TextField("", text: $name)
                .font(.subheadline)
                .frame(minWidth: 240)
        }

    }
    
    @ViewBuilder
    private var systemRows: some View {
        BaseGridRow("Memory") {
            UnitSlider(
                value: $memorySize,
                range: VMConfig.minimumAllowedMemorySize.B ... VMConfig.maximumAllowedMemorySize.B,
                step: 1.GB,
                units: [.mebibytes, .gibibytes]
            )
        }
        BaseGridRow("Disk Size") {
            UnitSlider(
                value: $diskSize,
                range: VMConfig.minimumAllowedDiskSize.B ... VMConfig.maximumAllowedDiskSize.B,
                step: 10.GB,
                units: [.mebibytes, .gibibytes]
            )
        }
        BaseGridRow("CPU Count") {
            UnitSlider(
                value: $cpuCount,
                range: VMConfig.minimumAllowedCPUCount.core ... VMConfig.maximumAllowedCPUCount.core,
                step: 1.core,
                units: []
            )
        }
    }
    
    @ViewBuilder
    private var advancedRows: some View {
        BaseGridRow("Advanced") {
            Toggle("Keyboard", isOn: $enableKeyboard).font(.subheadline)
        }
        GridRow {
            Spacer()
            Toggle("Audio", isOn: $enableAudio).font(.subheadline)
        }
        GridRow {
            Spacer()
            Toggle("Network", isOn: $enableNetwork).font(.subheadline)
        }
        GridRow {
            Spacer()
            Toggle("Console", isOn: $enableConsole).font(.subheadline)
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
                //
            } label: {
                Text("Next")
            }
            .keyboardShortcut(.defaultAction)
        }
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
        }
    }
}

struct InstallView_Previews: PreviewProvider {
    static var previews: some View {
        InstallView()
    }
}
