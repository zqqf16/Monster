//
//  VMPlayer.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/17.
//

import SwiftUI
import Virtualization


struct VMPlayer: NSViewRepresentable {
    typealias NSViewType = VZVirtualMachineView

    @ObservedObject var instance: VMInstance

    func makeNSView(context: Context) -> VZVirtualMachineView {
        let view = VZVirtualMachineView()
        view.virtualMachine = instance.virtualMachine
        return view
    }
    
    func updateNSView(_ nsView: VZVirtualMachineView, context: Context) {
        if let virtualMachine = instance.virtualMachine {
            nsView.virtualMachine = virtualMachine
        }
    }
}
