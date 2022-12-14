//
//  VirtualMachine.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/9.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Combine
import Foundation
import Virtualization

class VirtualMachine: ObservableObject, Identifiable {
    var id: String {
        config.id
    }

    enum State: Int {
        // The same with VZVirtualMachine.State
        case stopped = 0
        case running = 1
        case paused = 2
        case error = 3
        case starting = 4
        case pausing = 5
        case resuming = 6
        case stopping = 7

        // for macOS installing
        case installing = 100
    }

    @Published
    var state: State = .stopped

    @Published
    private(set) var installingProgress: Double = 0

    @Published
    var config: VMConfig = .defaultLinux

    @Published
    private(set) var instance: VMInstance!

    @Published
    private(set) var snapshot: NSImage?

    private(set) lazy var virtualMachineView: VZVirtualMachineView = .init()

    #if arch(arm64)
        private var installer: VMInstaller!
    #endif

    private var bundle: VMBundle! {
        if let bundleURL = config.bundleURL {
            return VMBundle(bundleURL)
        }
        return nil
    }

    private var configHelper: VMConfigHelper {
        #if arch(arm64)
            if config.os == .macOS {
                return MacOSConfigHelper(config: config, bundle: bundle)
            } else {
                return GenericConfigHelper(config: config, bundle: bundle)
            }
        #else
            return GenericConfigHelper(config: config, bundle: bundle)
        #endif
    }

    private var subscriptions = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    var name: String {
        config.name
    }

    init(config: VMConfig) {
        self.config = config
        loadSnpashot()
        startSnapshotTimer()
    }

    deinit {
        timerCancellable?.cancel()
        subscriptions.forEach { $0.cancel() }
    }
}

extension VirtualMachine: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VirtualMachine, rhs: VirtualMachine) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: Installation

extension VirtualMachine {
    #if arch(arm64)
        func checkInstallation() async throws {
            guard configHelper.needInstall else {
                return
            }

            if let installer = installer, installer.installing == true {
                print("Virtual machine is installing, do nothing")
                return
            }

            try await install()
        }

        @MainActor
        func install() async throws {
            state = .installing
            defer {
                state = .stopped
            }
            print("Start installing")
            installer = VMInstaller(configHelper)
            installer.$progress.assign(to: &$installingProgress)
            try await installer.install()

            config.installed = true
            try saveConfig()
        }
    #else
        func checkInstallation() async throws {
            //
        }
    #endif
}

// MARK: Control

extension VirtualMachine {
    @MainActor
    func run() async throws {
        if let instance = instance {
            switch instance.state {
            case .running:
                print("Virtual machine is running, do nothing")
                return
            case .paused:
                print("Virtual machine is paused, resume it")
                return try await resume()
            default:
                break
            }
        }

        try await checkInstallation()

        print("Start virtual machine")
        instance = VMInstance(configHelper)
        instance.$state.assign(to: &$state)

        instance.$virtualMachine.sink { [weak self] vm in
            self?.virtualMachineView.virtualMachine = vm
        }.store(in: &subscriptions)

        try await instance.start()
    }

    @MainActor
    func stop() async throws {
        try await instance.stop()
    }

    @MainActor
    func pause() async throws {
        try await instance.pause()
    }

    @MainActor
    func resume() async throws {
        try await instance.resume()
    }
}

// MARK: Bundle

extension VirtualMachine {
    convenience init(bundleURL: URL) throws {
        do {
            let config = try VMBundle(bundleURL).loadConfig()
            self.init(config: config)
        } catch {
            throw Failure("Failed to load config", reason: error)
        }
    }

    func prepareBundle() throws {
        do {
            try bundle.prepareBundleDirectory()
            try bundle.save(config: config)
        } catch {
            throw Failure("Failed to create virtual machine bundle", reason: error)
        }
    }

    func removeFiles() throws {
        guard let url = bundle?.url else { return }
        NSWorkspace.shared.recycle([url]) { _, error in
            if let error = error {
                print("Failed to remove virtual machine bundle: \(error.localizedDescription)")
            }
        }
    }

    func saveConfig() throws {
        do {
            try bundle?.save(config: config)
        } catch {
            throw Failure("Failed to save virtual machine configurations", reason: error)
        }
    }
}

// MARK: Snapshots

extension VirtualMachine {
    func takeSnapshot() {
        guard instance != nil, instance.state != .stopped else {
            return
        }
        let rect = virtualMachineView.bounds
        guard let rep = virtualMachineView.bitmapImageRepForCachingDisplay(in: rect) else {
            return
        }

        print("Taking snapshot ...")

        virtualMachineView.cacheDisplay(in: rect, to: rep)
        let img = NSImage(size: rect.size)
        img.addRepresentation(rep)

        snapshot = img
        try? bundle?.save(snapshot: img)
    }

    func startSnapshotTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 10, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.takeSnapshot()
            }
    }

    func loadSnpashot() {
        snapshot = bundle?.loadSnapshot()
    }
}
