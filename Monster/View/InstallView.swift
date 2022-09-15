//
//  GuideView.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//

import SwiftUI

struct InstallView: View {
    @State var config: VMConfig = .defaultLinux

    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    @State var linuxDictribution: OperatingSystem?

    @State var error: Error? = nil
    
    var body: some View {
        VStack {
            Spacer()
            Text("New Virtual Machine")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .italic()
            }
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
        }.onChange(of: config, perform: { newValue in
            error = nil
        })
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
                        os.wrappedValue = .macOS
                    case .linux:
                        os.wrappedValue = linuxDictribution ?? .linux
                    case .import:
                        openPanel()
                        break
                    case .none:
                        break
                    }
                }
            }
        )
    }
    
    private var os: Binding<OperatingSystem> {
        Binding {
            config.os
        } set: { value in
            config.os = value
            config.name = "\(value)"
        }
    }
    
    @ViewBuilder
    private var grid: some View {
        Grid(alignment: .leading, horizontalSpacing: 10) {
            generalRows
            Divider()
            systemRows
            Divider()
        }
    }
    
    private var distributionRow: some View {
        BaseGridRow("Linux Distribution") {
            HStack {
                Picker("", selection: os) {
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
        return BaseGridRow(config.os.restoreImageTitle) {
            FileButton(
                tips: config.os.restoreImageTips,
                url: $config.restoreImageURL
            )
            .font(.subheadline)
        }
    }
    
    @ViewBuilder
    private var generalRows: some View {
        if currentEntrance.wrappedValue == .linux {
            distributionRow
        }
        restoreImageRow
        BaseGridRow("Display Name") {
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
                range: VMConfig.memorySizeRange,
                step: 1.GB,
                units: [.mebibytes, .gibibytes]
            )
            .font(.subheadline)
        }
        BaseGridRow("Disk") {
            UnitSlider(
                value: $config.diskSize,
                range: VMConfig.diskSizeRange,
                step: 10.GB,
                units: [.mebibytes, .gibibytes]
            )
            .font(.subheadline)
        }
        BaseGridRow("CPUs") {
            UnitSlider(
                value: $config.cpuCount,
                range: VMConfig.cpuCountRnage,
                step: 1.core,
                units: []
            )
            .font(.subheadline)
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
                Text("Create")
            }
            .keyboardShortcut(.defaultAction)
        }
    }
    
    private func commit() {
        store.addVirtualMachine(with: config)
        dismiss()
    }
    
    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        guard panel.runModal() == .OK,
              let url = panel.url else {
            return
        }
        
        do {
            try store.importVirtualMachine(from: url)
            dismiss()
        } catch {
            self.error = error
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
        GridRow() {
            Text(title)
                .frame(minWidth: 120, alignment: .trailing)
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
