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
    @Published var selectedVM: VirtualMachine? {
        didSet {
            columnVisibility = selectedVM == nil ? .detailOnly : .all
        }
    }

    @Published var showWelcome: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var columnVisibility = NavigationSplitViewVisibility.all

    init() {
        loadVirtualMachines()

        if vms.count > 0 {
            selectedVM = vms[0]
        }
    }

    private func loadVirtualMachines() {
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

    func addVirtualMachine(with config: VMConfig, select _: Bool = true) {
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
            let index = min(index, vms.count - 1)
            selectedVM = vms[index]
        } else {
            selectedVM = nil
        }
    }

    @discardableResult
    func importVirtualMachine(from url: URL) throws -> VirtualMachine? {
        for vm in vms {
            if vm.config.bundleURL == url {
                selectedVM = vm
                throw Failure("Virtual machine already exists")
            }
        }

        let bundle = VMBundle(url)
        guard var config = try? bundle.loadConfig() else {
            throw Failure("Failed to load informations from file")
        }

        if vms.contains(where: { $0.id == config.id }) {
            print("There is already a virtual machine with the same ID \(config.id)")
            config.id = UUID().uuidString
        }

        let dest = VMBundle.generateBundleURL(for: config)
        do {
            print("Moving file from \(url.path) to \(dest.path)")
            try bundle.move(to: dest)
        } catch {
            throw Failure("Failed to move file", reason: error)
        }
        config.bundleURL = dest

        let vm = VirtualMachine(config: config)
        try? vm.saveConfig()

        vms.insert(vm, at: 0)
        selectedVM = vms[0]

        return vm
    }
}
