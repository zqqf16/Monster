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
        let directory = AppSettings.vmDirectory
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        let bundles = files.filter { $0.pathExtension == "vm" }

        bundles.forEach { url in
            let bundle = VMBundle(url)
            if let config = bundle.loadConfig() {
                vms.append(config)
            }
        }
    }
    
    func createVirtualMachine(with config: VMConfig, select: Bool = true) {
        let bundle = VMBundle(config)
        try? bundle.prepareBundleDirectory()
        try? bundle.save(config: config)

        vms.append(config)
        selectedVM = vms.last
        columnVisibility = .all
    }
    
    func remove(config: VMConfig, deleteFiles: Bool = true) {
        guard let index = vms.firstIndex(of: config) else {
            return
        }
        
        vms.remove(at: index)
        if deleteFiles {
            let bundle = VMBundle(config)
            try? bundle.remove()
        }
        
        if vms.count > 0 {
            let index = min(index, vms.count)
            selectedVM = vms[index]
        } else {
            selectedVM = nil
        }
    }
}
