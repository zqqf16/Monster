//
//  File.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/9.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import Virtualization

#if arch(arm64)

    /// VMInstaller Wrapper
    class VMInstaller {
        private var installer: VZMacOSInstaller!
        private var configHelper: VMConfigHelper
        private var observeToken: NSKeyValueObservation?

        @Published
        private(set) var virtualMachine: VZVirtualMachine!

        @Published
        private(set) var progress: Double = 0

        @Published
        private(set) var installing: Bool = false

        init(_ configHelper: VMConfigHelper) {
            self.configHelper = configHelper
        }

        deinit {
            observeToken?.invalidate()
        }

        func install() async throws {
            defer {
                installer = nil
            }

            let restoreImage = try await loadRestoreImage()
            try await startInstallation(restoreImage: restoreImage)
            try await virtualMachine.stop()
            virtualMachine = nil
        }

        private func loadRestoreImage() async throws -> VZMacOSRestoreImage {
            guard let restoreImageURL = configHelper.config.restoreImageURL else {
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
        private func startInstallation(restoreImage: VZMacOSRestoreImage) async throws {
            installing = true
            defer {
                installing = false
            }

            let virtualMachineConfiguration = try configHelper.createVirtualMachineConfiguration(restoreImage: restoreImage)
            virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
            installer = VZMacOSInstaller(virtualMachine: virtualMachine, restoringFromImageAt: restoreImage.url)

            observeToken?.invalidate()
            observeToken = installer.progress.observe(\.fractionCompleted, options: [.initial, .new]) { [weak self] progress, change in
                guard let self = self else { return }
                self.progress = change.newValue ?? Double(progress.completedUnitCount / progress.totalUnitCount)
                print("Installation progress: \(self.progress * 100)%")
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

            try await virtualMachine.stop()
        }
    }

#endif
