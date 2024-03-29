//
//  VMInstance.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/18.
//

import Foundation
import Virtualization

extension VZVirtualMachine {
    @MainActor
    func start() async throws {
        guard canStart else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.start(completionHandler: { result in
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
        guard canStop else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.stop { error in
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
        guard canPause else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.pause { result in
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
        guard canResume else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.resume { result in
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
}

/// VZVirtualMachine Wrapper
class VMInstance: NSObject, VZVirtualMachineDelegate {
    @Published
    var state: VirtualMachine.State = .stopped

    @Published
    private(set) var virtualMachine: VZVirtualMachine!

    private var configHelper: VMConfigHelper
    private var observeToken: NSKeyValueObservation?

    init(_ configHelper: VMConfigHelper) {
        self.configHelper = configHelper
    }

    deinit {
        observeToken?.invalidate()
    }

    private func configVirtualMachine() throws {
        let virtualMachineConfiguration = try configHelper.createVirtualMachineConfiguration()
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        virtualMachine.delegate = self

        observeToken?.invalidate()
        observeToken = virtualMachine.observe(\.state, options: [.initial, .new]) { [weak self] vm, _ in
            print("Virtual machine state: \(vm.state.rawValue)")
            if let state = VirtualMachine.State(rawValue: vm.state.rawValue) {
                self?.state = state
            }
        }
    }

    @MainActor
    func start() async throws {
        try configVirtualMachine()
        try await virtualMachine.start()
    }

    @MainActor
    func stop() async throws {
        try await virtualMachine.stop()
        virtualMachine = nil
    }

    func pause() async throws {
        try await virtualMachine.pause()
    }

    func resume() async throws {
        try await virtualMachine.resume()
    }

    // MARK: VZVirtualMachineDelegate methods.

    func virtualMachine(_: VZVirtualMachine, didStopWithError error: Error) {
        print("Virtual machine did stop with error: \(error.localizedDescription)")
    }

    func guestDidStop(_: VZVirtualMachine) {
        print("Guest did stop virtual machine.")
    }

    func virtualMachine(_: VZVirtualMachine, networkDevice _: VZNetworkDevice, attachmentWasDisconnectedWithError error: Error) {
        print("Network attachment was disconnected with error: \(error.localizedDescription)")
    }
}
