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
        loadVMConfigs()

        print(VMDisplay.defaultPPI)
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

        vms = bundles.compactMap { try? VirtualMachine(bundleURL: $0) }
    }
    
    // MARK: Virtual Machine

    func virtualMachine(with vmID: String) -> VirtualMachine? {
        vms.first { vm in
            vm.id == vmID
        }
    }
    
    func addVirtualMachine(with config: VMConfig, select: Bool = true) {
        var validatedConfig = config
        if validatedConfig.bundleURL == nil {
            validatedConfig.bundleURL = VMBundle.generateBundleURL(for: config)
        }

        let vm = VirtualMachine(config: validatedConfig)
        try? vm.prepareBundle()
        vms.append(vm)

        selectedVM = vms.last
        columnVisibility = .all
    }
    
    func remove(virtualMachine: VirtualMachine, deleteFiles: Bool = true) {
        guard let index = vms.firstIndex(of: virtualMachine) else {
            print("Virtual machine \(virtualMachine) not found")
            return
        }
        
        if deleteFiles {
            try? virtualMachine.removeFiles()
        }
        
        vms.remove(at: index)
        if vms.count > 0 {
            let index = min(index, vms.count-1)
            selectedVM = vms[index]
        } else {
            selectedVM = nil
        }
    }
}
