//
//  FileButton.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/5.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct FileButton: View {
    var readOnly: Bool = false
    
    var systemImageName: String = "folder.badge.plus"
    var readOnlySystemImageName: String = "rectangle.and.text.magnifyingglass"
    var deleteSystemImageName: String = "minus.circle.fill"

    var layoutDirection: LayoutDirection = .leftToRight
    var comment: String? = nil
    var showResult: Bool = true
    
    var textFont: Font? = nil

    @Binding var path: String?
    
    var body: some View {
        HStack {
            if layoutDirection == .leftToRight {
                button
                text
                if showDeleteButton {
                    removeButton
                }
            } else {
                text
                if showDeleteButton {
                    removeButton
                }
                button
            }
        }
    }
    
    private var showDeleteButton: Bool {
        return !readOnly && path != nil
    }
    
    func rightToLeft() -> FileButton {
        var newButton = self
        newButton.layoutDirection = .rightToLeft
        return newButton
    }
    
    func font(_ font: Font) -> FileButton {
        var newButton = self
        newButton.textFont = font
        return newButton
    }
    
    func hideResult() -> FileButton {
        var newButton = self
        newButton.showResult = false
        return newButton
    }
    
    @ViewBuilder
    private var button: some View {
        Button {
            if readOnly {
                showInFinder()
            } else {
                openPanel()
            }
        } label: {
            Image(systemName: readOnly ? readOnlySystemImageName : systemImageName)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var removeButton: some View {
        Button {
            self.path = nil
        } label: {
            Image(systemName: deleteSystemImageName).foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var text: some View {
        let aligment: TextAlignment = (layoutDirection == .leftToRight ? .leading : .trailing)
        if path == nil {
            if let comment = self.comment {
                Text(comment)
                    .multilineTextAlignment(aligment)
                    .lineLimit(1)
                    .font(textFont)
                    .italic()
            }
        } else if showResult {
            Text(path!)
                .multilineTextAlignment(aligment)
                .lineLimit(1)
                .font(textFont)
        }
    }
    
    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if let path = path {
            let url = URL(filePath: path)
            panel.directoryURL = url.deletingLastPathComponent()
            panel.nameFieldLabel = url.lastPathComponent
        }
        
        if panel.runModal() == .OK {
            self.path = panel.url?.relativePath
        }
    }
    
    private func showInFinder() {
        guard let path = path else {
            return
        }
        let url = URL(filePath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

struct FileButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FileButton(showResult: true, path: .constant("/root/path"))
            FileButton(readOnly: true, path: .constant("/root/path"))
        }
    }
}
