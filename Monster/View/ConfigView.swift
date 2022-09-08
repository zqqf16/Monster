//
//  ConfigView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI

struct ConfigView: View {
    
    @ObservedObject var config: VMConfig

    var editable: Bool = true
        
    @State private var enableLogging = false
    @State private var selectedColor = "Red"
    @State private var scale: Float = 0
    
    @State private var showName: Bool = false
    
    var body: some View {
        Form {
            generalSection
            drivesSection
            systemSection
            advanceSection
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(.background)
        .onReceive(config.objectWillChange) { _ in
            print("Config changed")
        }
    }
    
    @ViewBuilder
    private var generalSection: some View {
        Section("General") {
            BaseLine("Name") {
                TextField("", text: $config.name)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 240)
            }
            if config.os != .macOS {
                BaseLine("Linux Distribution") {
                    Picker("", selection: $config.os) {
                        ForEach(OperatingSystem.linuxDistributions) { os in
                            Text(os.name).tag(os)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.automatic)
                    .frame(maxWidth: 100)
                }
            }
            
            BaseLine("Path") {
                FileButton(
                    readOnly: true,
                    path: $config.bundlePath
                )
                .rightToLeft()
            }
        }
    }
    
    @ViewBuilder
    private var systemSection: some View {
        Section("System") {
            BaseLine("Memory Size", icon: "memorychip") {
                UnitSlider(
                    value: $config.memorySize,
                    range: VMConfig.memorySizeRange,
                    step: 1.GB,
                    units: [.mebibytes, .gibibytes],
                    defaultUnit: .gibibytes
                ).hideSlider()
            }
            BaseLine("Disk Size", icon: "internaldrive") {
                UnitSlider(
                    value: $config.diskSize,
                    range: VMConfig.diskSizeRange,
                    step: 10.GB,
                    units: [.mebibytes, .gibibytes],
                    defaultUnit: .gibibytes
                ).hideSlider()
            }
            BaseLine("CPU Count", icon: "cpu") {
                UnitSlider(
                    value: $config.cpuCount,
                    range: VMConfig.cpuCountRnage,
                    step: 1.core,
                    units: []
                ).hideSlider()
            }
        }
    }
    
    @ViewBuilder
    private var drivesSection: some View {
        Section("Drives") {
            BaseLine(config.os.restoreImageTitle, icon: "externaldrive") {
                FileButton(path: $config.restoreImagePath)
                    .rightToLeft()
            }
            BaseLine("Boot from iso", icon: "power") {
                Toggle("", isOn: .constant(false))
            }
        }
    }
    
    private var sharedFolderTips: String {
        "Run `mount -t virtiofs MonsterShared ~/Monster` in vm"
    }

    @ViewBuilder
    private var advanceSection: some View {
        Section("Advanced") {
            BaseLine("Shared Folder", icon: "folder") {
                VStack(alignment: .trailing) {
                    FileButton(canChooseDirectories: true, canChooseFiles: false, path: sharedFolder)
                        .rightToLeft()
                    if sharedFolder.wrappedValue != nil {
                        Text(sharedFolderTips)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .italic()
                            .textSelection(.enabled)
                    }
                }
            }
        }
    }
    
    private var sharedFolder: Binding<String?> {
        // TODO: Only supports one directory now
        Binding {
            config.shareFolders.first?.path
        } set: {
            if let path = $0 {
                config.shareFolders = [URL(filePath: path)]
            } else {
                config.shareFolders.removeAll()
            }
        }
    }
}

private struct BaseLine<Content>: View where Content: View {
    var title: String
    var icon: String?
    
    @ViewBuilder var contentBilder: () -> Content
    
    init(_ title: String = "", icon: String? = nil, @ViewBuilder contentBilder: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.contentBilder = contentBilder
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
            }
            
            Text(title)
            Spacer()
            contentBilder()
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(config: .defaultMacOSConfig)
    }
}
