//
//  Sidebar.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/10.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        List(store.vms, selection: selection) { vm in
            NavigationLink(value: vm) {
                Image(vm.config.icon)
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.name)
                        .fontWeight(.semibold)
                    Text("\(vm.config.os.name)")
                        .font(.subheadline)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
    }
    
    var selection: Binding<VirtualMachine?> {
        Binding {
            store.selectedVM
        } set: { value in
            if value != nil {
                // List will clear selection at initialization
                // It might be a bug
                store.selectedVM = value
            }
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Sidebar().environmentObject(Store())
        }
    }
}
