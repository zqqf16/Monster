//
//  ShareFolderView.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/14.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct ShareFolderView: View {
    @ObservedObject var vm: VirtualMachine
    @State var selected: String?

    var body: some View {
        VStack(spacing: 0) {
            Table($vm.config.shareFolders, selection: $selected) {
                TableColumn("#") { folder in
                    Toggle("", isOn: enableWrapper(folder))
                        .labelsHidden()
                }.width(18)
                TableColumn("Name") { folder in
                    Text(folder.wrappedValue.name)
                        .font(.subheadline)
                }
                TableColumn("Path") { folder in
                    Text(folder.wrappedValue.url.path)
                        .font(.subheadline)
                }
                TableColumn("Read Only") { folder in
                    Toggle("", isOn: folder.readOnly)
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
            let folder = VMShareFolder(enable: true, url: url, readOnly: false)
            self.vm.config.shareFolders.append(folder)
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

        vm.config.shareFolders.removeAll { folder in
            folder.id == id
        }
    }

    private func enableWrapper(_ folder: Binding<VMShareFolder>) -> Binding<Bool> {
        Binding {
            folder.enable.wrappedValue
        } set: { value in
            if !value {
                folder.enable.wrappedValue = false
                return
            }

            if folder.wrappedValue.restoreFileAccess() {
                folder.enable.wrappedValue = true
            } else {
                folder.enable.wrappedValue = askPermission(for: folder.url.wrappedValue)
            }
        }
    }
}

struct ShareFolderView_Previews: PreviewProvider {
    static var previews: some View {
        ShareFolderView(vm: VirtualMachine(config: .defaultLinux))
    }
}
