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

    @ObservedObject var vm: VirtualMachine

    func makeNSView(context _: Context) -> VZVirtualMachineView {
        return vm.virtualMachineView
    }

    func updateNSView(_: VZVirtualMachineView, context _: Context) {}
}
