//
//  VMManager.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/17.
//

import Virtualization

class VMManager {
    
    static let shared = VMManager()
    
    var allInstances: [VMConfig: VMInstance] = [:]
    
    func getInstance(with config: VMConfig) -> VMInstance {
        if let instance = allInstances[config] {
            return instance
        }
        let instance = VMInstance(config)
        allInstances[config] = instance
        return instance
    }
}
