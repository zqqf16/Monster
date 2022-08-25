//
//  ContentView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @State private var isHovering = false

    var body: some View {
        NavigationSplitView(columnVisibility: $store.columnVisibility) {
            Sidebar()
        } detail: {
            if let selectedVM = store.selectedVM {
                ConfigView(vm: selectedVM)
            } else {
                EmptyStateView()
            }
        }
        .toolbar {
            Toolbar()
        }
        .sheet(isPresented: $store.showWelcome) {
            WelcomeView()
        }
        .alert(alertTitle, isPresented: $store.showDeleteAlert) {
            alert
        }
    }

    var alertTitle: String {
        let name = store.selectedVM?.name ?? ""
        return "Delete \(name)?"
    }
    
    @ViewBuilder var alert: some View {
        Button("Delete", role: .destructive) {
            if let selectedVM = store.selectedVM {
                store.remove(vm: selectedVM)
            }
        }
        Button("Cancel", role: .cancel) {
            //
        }
    }
}

private struct EmptyStateView: View {
    @EnvironmentObject private var store: Store
    @State private var isHovering = false

    var body: some View {
        Button {
            store.showWelcome = true
        } label: {
            HStack {
                Image(systemName: "plus")
                    .foregroundColor(.accentColor)
                Text("Create a virtual machine")
                    .font(.title3)
            }
        }
        .buttonStyle(.plain)
        .shadow(radius: 0)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AnyShapeStyle(BackgroundStyle()))
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isHovering ? Color.accentColor : .clear)
        }
        
        .scaleEffect(isHovering ? 1.02 : 1)
        .onHover { isHovering in
            withAnimation {
                self.isHovering = isHovering
            }
        }
    }
}

private struct Toolbar: ToolbarContent {
    @EnvironmentObject private var store: Store
    @Environment(\.openWindow) private var openWindow

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            Button {
                if let selectedVM = store.selectedVM {
                    openWindow(value: selectedVM)
                }
            } label: {
                Label("Run", systemImage: "play.fill")
            }
            .disabled(store.selectedVM == nil)
            .keyboardShortcut("r", modifiers: .command)

            Button {
                store.showDeleteAlert = true
            } label: {
                Label("Pause", systemImage: "pause.fill")
            }
            .keyboardShortcut(.delete)

            Button {
                //
            } label: {
                Label("Stop", systemImage: "stop.fill")
            }
        }
        ToolbarItem() {
            Spacer()
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                store.showWelcome = true
            } label: {
                Label("Create a new VM", systemImage: "plus")
            }
            .keyboardShortcut("+", modifiers: .command)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Store())
    }
}
