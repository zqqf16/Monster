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
        let fileManager = FileManager.default
        let directory = Settings.vmDirectory
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        let bundles = files.filter { $0.pathExtension == "vm" }

        bundles.forEach { url in
            let bundle = VMBundle(url)
            if let config = bundle.loadConfig() {
                vms.append(config)
            }
        }
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
