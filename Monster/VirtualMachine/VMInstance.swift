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
    
    @Published var currentError: Error?
        
    /// macOS installing progress
    @Published var installingProgress: Double = 0
    
    /// Current virtual machine
    @Published private(set) var virtualMachine: VZVirtualMachine!
    
    private var observeToken: NSKeyValueObservation?

    init(_ config: VMConfig) {
        self.config = config
    }
    
    deinit {
        observeToken?.invalidate()
    }
    
    func configVirtualMachine() throws {
        if virtualMachine != nil {
            return
        }
        let configHelper = VMConfigHelper(config: config)
        let virtualMachineConfiguration = try configHelper.createVirtualMachineConfiguration()
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        
        observeToken = virtualMachine.observe(\.state) {[weak self] vm, change in
            print("Virtual machine state: \(vm.state.rawValue)")
            if let state = State(rawValue: vm.state.rawValue) {
                self?.state = state
            }
        }
        
        virtualMachine.delegate = self
    }
    
    func run() throws {
        try configVirtualMachine()

        if virtualMachine.state == .running {
            return
        }
        
        if virtualMachine.canResume {
            virtualMachine.resume { result in
                switch result {
                case let .failure(error):
                    fatalError("Virtual machine failed to start with error: \(error)")

                default:
                    print("Virtual machine successfully started.")
                 }
            }
            return
        }
        
        if !virtualMachine.canStart {
            return
        }
                
        virtualMachine.start(completionHandler: { (result) in
            switch result {
            case let .failure(error):
                fatalError("Virtual machine failed to start with error: \(error)")

            default:
                print("Virtual machine successfully started.")
             }
        })
    }
    
    func stop() {
        virtualMachine?.stop { error in
            if let _ = error {
                print("Virtual machine did stop with error: \(error!.localizedDescription)")
            }
        }
        virtualMachine = nil
    }
    
    func pause() {
        virtualMachine?.pause { result in
            switch result {
            case let .failure(error):
                fatalError("Virtual machine failed to pause with error: \(error)")
            default:
                print("Virtual machine successfully paused.")
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
