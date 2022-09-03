//
//  ConfigView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI

struct ConfigView: View {
    
    @ObservedObject var vm: VMConfig

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
    }
    
    @ViewBuilder
    private var generalSection: some View {
        Section("General") {
            BaseLine(title: "Name") {
                TextField("", text: $vm.name)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 240)
            }
            BaseLine(title: "Operating System") {
                Picker("", selection: $vm.os) {
                    ForEach(OperatingSystem.allCases) { os in
                        Text(os.name).tag(os.rawValue)
                    }
                }.labelsHidden()
                .pickerStyle(.automatic)
                .frame(maxWidth: 100)
            }
        }
    }
    
    @ViewBuilder
    private var systemSection: some View {
        Section("System") {
            BaseLine(title: "Memory", icon: "memorychip") {
                Text("\(vm.memorySize.gb) GB")
                    .multilineTextAlignment(.trailing)
                Stepper("", value: $vm.memorySize.value, step: 1).labelsHidden()
            }
            BaseLine(title: "Disk", icon: "internaldrive") {
                Text("\(vm.diskSize.gb) GB")
                    .multilineTextAlignment(.trailing)
                Stepper("", value: $vm.diskSize.value, step: 1).labelsHidden()
            }
            BaseLine(title: "CPUs", icon: "cpu") {
                Text("\(vm.cpuCount.count)")
                    .multilineTextAlignment(.trailing)
                Stepper("", value: $vm.cpuCount.value, step: 1).labelsHidden()
            }
        }
    }
    
    @ViewBuilder
    private var drivesSection: some View {
        Section("Drives") {
            PathLine(title: vm.os == .macOS ? "IPSW" : "ISO", icon: "opticaldiscdrive", path: $vm.restoreImagePath)

            BaseLine(title: "Boot from iso", icon: "power") {
                Toggle("", isOn: .constant(false))
            }
        }
    }

    @ViewBuilder
    private var advanceSection: some View {
        Section("Advanced") {
            PathLine(title: "Shared Directory", icon: "folder", path: $vm.restoreImagePath)
        }
    }
}

private struct BaseLine<Content> : View where Content : View {
    var title: String = ""
    var icon: String?
    
    @ViewBuilder var contentBilder: () -> Content
    
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

private struct PathLine : View {
    var title: String = ""
    var icon: String?
    
    @Binding var path: String?
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon).foregroundColor(.accentColor)
            }
            Text(title)
            Spacer()
            Text(path ?? "")
                .multilineTextAlignment(.trailing)
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                if panel.runModal() == .OK {
                    self.path = panel.url?.relativePath
                }
            } label: {
                Image(systemName: "folder.badge.plus")
            }.buttonStyle(.plain)
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(vm: .defaultMacOSConfig)
    }
}
