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
        Form {
            generalSection
            drivesSection
            systemSection
            advanceSection
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(.background)
        .onReceive(vm.$config.debounce(for: .milliseconds(1000), scheduler: RunLoop.main), perform: { config in
            print("Virtual machine configurations changed")
            try? self.vm.saveConfig()
        })
    }
    
    @ViewBuilder
    private var generalSection: some View {
        Section("General") {
            BaseLine("Name") {
                TextField("", text: $vm.config.name)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 240)
            }
            if vm.config.os != .macOS {
                BaseLine("Linux Distribution") {
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
            
            BaseLine("Path") {
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
            BaseLine("Memory", icon: "memorychip") {
                UnitSlider(
                    value: $vm.config.memorySize,
                    range: VMConfig.memorySizeRange,
                    step: 1.GB,
                    units: [.mebibytes, .gibibytes],
                    defaultUnit: .gibibytes
                ).hideSlider()
            }
            BaseLine("Disk", icon: "internaldrive") {
                UnitSlider(
                    value: $vm.config.diskSize,
                    range: VMConfig.diskSizeRange,
                    step: 10.GB,
                    units: [.mebibytes, .gibibytes],
                    defaultUnit: .gibibytes
                ).hideSlider()
            }
            BaseLine("CPUs", icon: "cpu") {
                UnitSlider(
                    value: $vm.config.cpuCount,
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
            BaseLine(vm.config.os.restoreImageTitle, icon: "externaldrive") {
                FileButton(url: $vm.config.restoreImageURL)
                    .rightToLeft()
            }
        }
    }
    
    private var sharedFolderTips: String {
        "Run `mount -t virtiofs MonsterShared ~/Monster` in vm"
    }

    @ViewBuilder
    private var advanceSection: some View {
        Section("Advanced") {
            BaseLine("Shared Folder", icon: "folder", tips: sharedFolderTips) {
                FileButton(canChooseDirectories: true, canChooseFiles: false, url: sharedFolder)
                    .rightToLeft()
            }
        }
    }
    
    private var sharedFolder: Binding<URL?> {
        // TODO: Only supports one directory now
        Binding {
            vm.config.shareFolders.first
        } set: {
            if let url = $0 {
                vm.config.shareFolders = [url]
            } else {
                vm.config.shareFolders.removeAll()
            }
        }
    }
}

private struct BaseLine<Content>: View where Content: View {
    var title: String
    var icon: String?
    var tips: String?

    @ViewBuilder var contentBilder: () -> Content
    
    init(_ title: String = "", icon: String? = nil, tips: String? = nil, @ViewBuilder contentBilder: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.tips = tips
        self.contentBilder = contentBilder
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                }
                
                Text(title)
                Spacer()
                contentBilder()
            }
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
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(vm: VirtualMachine(config: .defaultMacOS))
    }
}
