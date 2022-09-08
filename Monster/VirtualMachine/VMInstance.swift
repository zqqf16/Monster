//
//  VMInstance.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/18.
//

import Foundation
import Virtualization

class VMInstance: NSObject, VZVirtualMachineDelegate, ObservableObject {

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
    
    var config: VMConfig

    /// Virtual machine state
    @Published var state: State = .stopped
    
    @Published var currentError: Failure?
        
    /// macOS installing progress
    @Published var installingProgress: Double = 0
    
    /// Current virtual machine
    private(set) var virtualMachine: VZVirtualMachine!

    /// Current virtual machine view
    private(set) var virtualMachineView: VZVirtualMachineView = VZVirtualMachineView()
    
    private var observeToken: NSKeyValueObservation?

    private var configHelper: VMConfigHelper

#if arch(arm64)
    private var installer: VZMacOSInstaller!
#endif

    init(_ config: VMConfig) {
        self.config = config
#if arch(arm64)
        if config.os == .macOS {
            self.configHelper = MacOSConfigHelper(config)
        } else {
            self.configHelper = GenericConfigHelper(config)
        }
#else
        self.configHelper = GenericConfigHelper(config)
#endif
    }
    
    deinit {
        observeToken?.invalidate()
    }
    
    private func configVirtualMachine() throws {
        let virtualMachineConfiguration = try configHelper.createVirtualMachineConfiguration()
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        virtualMachine.delegate = self

        observeToken?.invalidate()
        observeToken = virtualMachine.observe(\.state) {[weak self] vm, change in
            print("Virtual machine state: \(vm.state.rawValue)")
            if let state = State(rawValue: vm.state.rawValue) {
                self?.state = state
            }
        }
    }
    
    @MainActor
    func run() async throws {
        do {
            try await startIfNeed()
        } catch {
            if let error = error as? Failure {
                self.currentError = error
            } else {
                self.currentError = Failure("Unknow error", reason: error)
            }
            self.state = .error
            throw self.currentError!
        }
    }
    
    @MainActor
    private func startIfNeed() async throws {
#if !arch(arm64)
        if config.os == .macOS {
            throw Failure("MacOS is not supported on this device")
        }
#endif
        if virtualMachine != nil {
            if state == .running || state == .installing {
                return
            }
            if virtualMachine.canResume {
                try await resume()
                return
            }
        }

#if arch(arm64)
        if configHelper.needInstall {
            try await install()
            self.state = .stopped
        }
#endif
        
        try await start()
    }
    
    @MainActor
    func start() async throws {
        try configVirtualMachine()
        virtualMachineView.virtualMachine = virtualMachine
        if !virtualMachine.canStart {
            throw Failure("Virtual machine cannot start")
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            virtualMachine.start(completionHandler: { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: Failure("Virtual machine started failed", reason: error))
                case let .success(restoreImage):
                    print("Virtual machine successfully started.")
                    continuation.resume(returning: restoreImage)
                }
            })
        }
    }
    
    @MainActor
    func stop() async throws {
        guard let virtualMachine = self.virtualMachine else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            virtualMachine.stop { [weak self] error in
                guard let self = self else { return }
                self.virtualMachine = nil
                self.virtualMachineView.virtualMachine = nil
                if let _ = error {
                    print("Virtual machine did stop with error: \(error!.localizedDescription)")
                    continuation.resume(throwing: Failure("Virtual machine failed to stop", reason: error))
                } else {
                    print("Virtual machine successfully stopped.")
                    continuation.resume()
                }
            }
        }
    }
    
    @MainActor
    func pause() async throws {
        guard let virtualMachine = self.virtualMachine else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            virtualMachine.pause { result in
                switch result {
                case let .failure(error):
                    print("Virtual machine failed to pause with error: \(error)")
                    continuation.resume(throwing: Failure("Virtual machine failed to pause", reason: error))
                default:
                    print("Virtual machine successfully paused.")
                    continuation.resume()
                }
            }
        }
    }
    
    @MainActor
    func resume() async throws {
        guard let virtualMachine = self.virtualMachine else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            virtualMachine.resume { result in
                switch result {
                case let .failure(error):
                    print("Virtual machine failed to resume with error: \(error)")
                    continuation.resume(throwing: Failure("Virtual machine failed to resume", reason: error))
                default:
                    print("Virtual machine successfully resumed.")
                    continuation.resume()
                }
            }
        }
    }

    /*
    func takeSnapshot() {
        let rect = virtualMachineView.bounds
        guard let rep = virtualMachineView.bitmapImageRepForCachingDisplay(in: rect) else {
            return
        }
        self.virtualMachineView.cacheDisplay(in: rect, to: rep)
        let img = NSImage(size: rect.size)
        img.addRepresentation(rep)
        debugPrint(img)
    }
     */

    // MARK: VZVirtualMachineDelegate methods.

    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        print("Virtual machine did stop with error: \(error.localizedDescription)")
    }

    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        print("Guest did stop virtual machine.")
    }

    func virtualMachine(_ virtualMachine: VZVirtualMachine, networkDevice: VZNetworkDevice, attachmentWasDisconnectedWithError error: Error) {
        print("Netowrk attachment was disconnected with error: \(error.localizedDescription)")
    }
}

#if arch(arm64)

// MARK: MacOS Installation
extension VMInstance {
    func install() async throws {
        defer {
            installer = nil
        }
        do {
            let restoreImage = try await self.loadRestoreImage()
            try await self.startInstallation(restoreImage: restoreImage)
            try await self.stop()
        } catch let error as Failure {
            print("\(error.localizedDescription) \n \(error.reason?.localizedDescription ?? "")")
            throw error
        } catch {
            throw error
        }
    }

    func loadRestoreImage() async throws -> VZMacOSRestoreImage {
        guard let restoreImageURL = config.restoreImageURL else {
            throw Failure("Restore image path shouldn't be nil")
        }
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<VZMacOSRestoreImage, Error>) in
            VZMacOSRestoreImage.load(from: restoreImageURL) { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: Failure("Failed to load restore image", reason: error))
                case let .success(restoreImage):
                    continuation.resume(returning: restoreImage)
                }
            }
        }
    }
    
    @MainActor
    func startInstallation(restoreImage: VZMacOSRestoreImage) async throws {
        self.state = .installing

        let configHelper = MacOSConfigHelper(self.config)
        let virtualMachineConfiguration = try configHelper.createVirtualMachineConfiguration(restoreImage: restoreImage)
        
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        virtualMachine.delegate = self
        virtualMachineView.virtualMachine = virtualMachine

        installer = VZMacOSInstaller(virtualMachine: virtualMachine, restoringFromImageAt: restoreImage.url)

        observeToken = installer.progress.observe(\.fractionCompleted, options: [.initial, .new]) { [weak self] (progress, change) in
            guard let self = self else { return }
            self.installingProgress = change.newValue ?? Double(progress.completedUnitCount / progress.totalUnitCount)
            print("Installation progress: \(self.installingProgress * 100)%")
        }
        
        print("Starting installation")

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            installer.install(completionHandler: { result in
                if case let .failure(error) = result {
                    continuation.resume(throwing: Failure("Failed to install virtual machine", reason: error))
                } else {
                    continuation.resume()
                    print("Installation succeeded")
                }
            })
        }
        
        config.installed = true
    }
}

#endif
