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
        DispatchQueue.main.async {
            updateWindowSize()
        }
        return vm.virtualMachineView
    }

    func updateNSView(_: VZVirtualMachineView, context _: Context) {}
    
    func updateWindowSize() {
        guard let window = vm.virtualMachineView.window else {
            return
        }
        let origin = window.frame.origin
        let size = CGSize(width: vm.config.display.width, height: vm.config.display.height)
        window.setFrame(CGRect(origin: origin, size: size), display: true, animate: false)
    }
}
