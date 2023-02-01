//
//  ShareDirectoryView.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/14.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct ShareDirectoryView: View {
    @ObservedObject var vm: VirtualMachine
    @State var selected: String?

    var body: some View {
        VStack(spacing: 0) {
            Table($vm.config.shareDirectories, selection: $selected) {
                TableColumn("#") { directory in
                    Toggle("", isOn: enableWrapper(directory))
                        .labelsHidden()
                }.width(18)
                TableColumn("Name") { directory in
                    Text(directory.wrappedValue.name)
                        .font(.subheadline)
                }
                TableColumn("Path") { directory in
                    Text(directory.wrappedValue.url.path)
                        .font(.subheadline)
                }
                TableColumn("Read Only") { directory in
                    Toggle("", isOn: directory.readOnly)
                        .labelsHidden()
                }
                .width(80)
            }.tableStyle(.inset)

            HStack {
                Button {
                    openPanel()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                Button {
                    removeSelection()
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(4)
        }
        .background {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(.secondary.opacity(0.2))
        }
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        guard panel.runModal() == .OK else {
            return
        }

        panel.urls.forEach { url in
            let directory = VMShareDirectory(enable: true, url: url, readOnly: false)
            self.vm.config.shareDirectories.append(directory)
        }
    }

    private func askPermission(for url: URL) -> Bool {
        let openPanel = NSOpenPanel()
        openPanel.message = "Monster needs to access this path to continue. Click Allow to continue."
        openPanel.prompt = "Allow"
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.directoryURL = url

        let response = openPanel.runModal()
        return response == .OK
    }

    private func removeSelection() {
        guard let id = selected else {
            return
        }

        vm.config.shareDirectories.removeAll { directory in
            directory.id == id
        }
    }

    private func enableWrapper(_ directory: Binding<VMShareDirectory>) -> Binding<Bool> {
        Binding {
            directory.enable.wrappedValue
        } set: { value in
            if !value {
                directory.enable.wrappedValue = false
                return
            }

            if directory.wrappedValue.restoreFileAccess() {
                directory.enable.wrappedValue = true
            } else {
                directory.enable.wrappedValue = askPermission(for: directory.url.wrappedValue)
            }
        }
    }
}

struct ShareDirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        ShareDirectoryView(vm: VirtualMachine(config: .defaultLinux))
    }
}
