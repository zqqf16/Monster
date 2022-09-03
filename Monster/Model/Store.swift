//
//  AppStore.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/15.
//

import Foundation
import SwiftUI

class Store: ObservableObject {
    @Published var vms: [VMConfig] = []
    @Published var selectedVM: VMConfig?

    @Published var showWelcome: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var columnVisibility = NavigationSplitViewVisibility.all

    init() {
        loadVMConfigs()

        if vms.count > 0 {
            selectedVM = vms[0]
        }
        
        columnVisibility = selectedVM == nil ? .detailOnly : .all
    }
    
    private func loadVMConfigs() {
#if DEBUG
        vms = [
            VMConfig("macOS 12.2", os: .macOS, memorySize: 8.GB, diskSize: 40.GB, cpuCount: 4.core),
            VMConfig("Ubuntu 22.04 LTS", os: .ubuntu, memorySize: 8.GB, diskSize: 40.GB, cpuCount: 4.core),
            VMConfig("Debian 11.3", os: .debian, memorySize: 8.GB, diskSize: 40.GB, cpuCount: 4.core),
            VMConfig("RHEL 9", os: .redhat, memorySize: 8.GB, diskSize: 40.GB, cpuCount: 4.core),
            VMConfig("Fedora 36", os: .fedora, memorySize: 8.GB, diskSize: 40.GB, cpuCount: 4.core),
            VMConfig("Arch", os: .arch, memorySize: 8.GB, diskSize: 40.GB, cpuCount: 4.core)
        ]
        
        let demoURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Ubuntu 20.04.vm")
        if FileManager.default.fileExists(atPath: demoURL.path) {
            let demoBundle = VMBundle(demoURL)
            if let config = demoBundle.loadConfig() {
                vms.insert(config, at: 0)
            }
        }
#endif
    }
    
    func append(vm: VMConfig, select: Bool = true) {
        vms.append(vm)
        selectedVM = vms.last
        columnVisibility = .all
    }
    
    func remove(vm: VMConfig) {
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
