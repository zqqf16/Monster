//
//  VMPlayer.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/17.
//

import SwiftUI
import Virtualization

struct VMPlayer: NSViewRepresentable {

    var vm: VMInstance!
    
    func makeNSView(context: Context) -> some NSView {
        let view = VZVirtualMachineView()
        do {
            try vm.run()
        } catch {
            print(error)
        }
        view.virtualMachine = vm.virtualMachine
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        //
    }
}
