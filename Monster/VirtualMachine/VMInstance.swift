//
//  VMInstance.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/18.
//

import Foundation
import Virtualization

class VMInstance: NSObject, VZVirtualMachineDelegate, ObservableObject {

    var config: VMConfig
    
    private(set) var virtualMachine: VZVirtualMachine!

    init(_ config: VMConfig) {
        self.config = config
    }
    
    func run() throws {
        let virtualMachineConfiguration = try config.createVirtualMachineConfiguration()
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        virtualMachine.delegate = self
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
        virtualMachine.stop { error in
            if let _ = error {
                print("Virtual machine did stop with error: \(error!.localizedDescription)")
            }
        }
    }
    
    func pause() {
        virtualMachine.pause { result in
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
