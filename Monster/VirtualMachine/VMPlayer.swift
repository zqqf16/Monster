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
        return instance.virtualMachineView
    }
    
    func updateNSView(_ nsView: VZVirtualMachineView, context: Context) {

    }
}
