//
//  ConfigView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI

struct ConfigView: View {

    @ObservedObject var vm: VirtualMachine
    
    var editable: Bool = true
    
    @State private var enableLogging = false
    @State private var selectedColor = "Red"
    @State private var scale: Float = 0
    
    @State private var showName: Bool = false

    var body: some View {
        ScrollView {
            header
            Form {
                generalSection
                systemSection
                drivesSection
                advanceSection
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(.background)
        .onReceive(vm.$config.debounce(for: .milliseconds(1000), scheduler: RunLoop.main), perform: { config in
            print("Virtual machine configurations changed")
            try? self.vm.saveConfig()
        })
    }
    
    @ViewBuilder
    private var header: some View {
        VStack {
            SnapshotView(vm: vm)
            
            TextField("", text: $vm.config.name)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
        }
        .padding()
    }
    
    @ViewBuilder
    private var generalSection: some View {
        Section {
            if vm.config.os != .macOS {
                BaseLine("Linux Distribution", icon: "LinuxIcon") {
                    Picker("", selection: $vm.config.os) {
                        ForEach(OperatingSystem.linuxDistributions) { os in
                            Text(os.name).tag(os)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.automatic)
                    .frame(maxWidth: 100)
                }
            }
            
            BaseLine("Path", systemIcon: "archivebox") {
                FileButton(
                    readOnly: true,
                    url: $vm.config.bundleURL
                )
                .rightToLeft()
            }
        }
    }
    
    @ViewBuilder
    private var systemSection: some View {
        Section("System") {
            BaseLine("Memory", systemIcon: "memorychip") {
                UnitSlider(
                    value: $vm.config.memorySize,
                    range: VMConfig.memorySizeRange,
                    step: 1.GB,
                    units: [.mebibytes, .gibibytes],
                    defaultUnit: .gibibytes
                ).hideSlider()
            }
            BaseLine("CPUs", systemIcon: "cpu") {
                UnitSlider(
                    value: $vm.config.cpuCount,
                    range: VMConfig.cpuCountRnage,
                    step: 1.core,
                    units: []
                ).hideSlider()
            }
            BaseLine("Display", systemIcon: "display") {
                DisplayField(display: $vm.config.display)
                DisplayPicker(selected: $vm.config.display)
            }
        }
    }
    
    @ViewBuilder
    private var drivesSection: some View {
        Section("Drives") {
            BaseLine(
                "Disk",
                systemIcon: "internaldrive",
                tips: "Boot disk cannot be resized after creation"
            ) {
                Text("\(vm.config.diskSize.gb) GiB")
            }
            
            BaseLine(
                vm.config.os.restoreImageTitle,
                systemIcon: "opticaldisc",
                tips: vm.config.os.restoreImageTips
            ) {
                FileButton(
                    url: $vm.config.restoreImageURL
                )
                .rightToLeft()
            }
        }
    }
    
    private var shareFolderTips: String {
        "Run `mount -t virtiofs MonsterShared ~/Monster` in vm"
    }
    
    @ViewBuilder
    private var advanceSection: some View {
        Section("Advanced") {
            VStack(alignment: .trailing) {
                HStack {
                    Image(systemName: "folder")
                        .frame(width: 18, height: 18)
                        .foregroundColor(.accentColor)
                    Text("Shared Folder")
                    Spacer()
                }
                HStack {
                    Spacer()
                    ShareFolderView(vm: vm)
                }
                Text(shareFolderTips)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .italic()
                    .textSelection(.enabled)
            }
        }
    }
}

private struct BaseLine<Content>: View where Content: View {
    var title: String
    var icon: String?
    var systemIcon: String?
    var tips: String?
    
    @ViewBuilder var contentBilder: () -> Content
    
    init(_ title: String = "", icon: String? = nil, systemIcon: String? = nil, tips: String? = nil, @ViewBuilder contentBilder: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.systemIcon = systemIcon
        self.tips = tips
        self.contentBilder = contentBilder
    }
    
    var body: some View {
        if tips != nil {
            VStack(alignment: .trailing) {
                contentView
                tipsView
            }
        } else {
            contentView
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        HStack {
            if let icon = systemIcon {
                Image(systemName: icon)
                    .frame(width: 18, height: 18)
                    .foregroundColor(.accentColor)
            } else if let icon = icon {
                Image(icon)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.accentColor)
            }
            Text(title)
            Spacer()
            contentBilder()
        }
    }
    
    @ViewBuilder
    var tipsView: some View {
        if let tips = tips {
            Spacer()
            Text(tips)
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
                .textSelection(.enabled)
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(vm: VirtualMachine(config: .defaultLinux))
            .frame(minHeight: 800)
    }
}
