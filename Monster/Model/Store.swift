//
//  AppStore.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/15.
//

import Foundation
import SwiftUI

class Store: ObservableObject {
    @Published var vms: [VirtualMachine] = []
    @Published var selectedVM: VirtualMachine?

    @Published var showWelcome: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var columnVisibility = NavigationSplitViewVisibility.all

    init() {
        loadVirtualMachines()

        if vms.count > 0 {
            selectedVM = vms[0]
        }
        
        columnVisibility = selectedVM == nil ? .detailOnly : .all
    }
    
    private func loadVirtualMachines() {
#if DEBUG
    vms = [
        VirtualMachine(name: "macOS 12.2", os: .macOS, memory: 8, disk: 40, cpu: 4),
        VirtualMachine(name: "Ubuntu 22.04 LTS", os: .ubuntu, memory: 4, disk: 30, cpu: 4),
        VirtualMachine(name: "Debian 11.3", os: .debian, memory: 4, disk: 30, cpu: 4),
        VirtualMachine(name: "RHEL 9", os: .linux, memory: 4, disk: 30, cpu: 4),
        VirtualMachine(name: "Fedora 36", os: .fedora, memory: 4, disk: 30, cpu: 4),
        VirtualMachine(name: "Arch", os: .linux, memory: 4, disk: 30, cpu: 4),
        VirtualMachine(name: "Oracle Linux 8", os: .linux, memory: 4, disk: 30, cpu: 4),
    ]
#endif
    }
    
    func append(vm: VirtualMachine, select: Bool = true) {
        vms.append(vm)
        selectedVM = vms.last
        columnVisibility = .all
    }
    
    func remove(vm: VirtualMachine) {
        guard let index = vms.firstIndex(of: vm) else {
            return
        }
        vms.remove(at: index)
        
        if vms.count > 0 {
            let index = min(index, vms.count)
            selectedVM = vms[index]
        } else {
            selectedVM = nil
        }
    }
}