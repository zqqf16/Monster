//
//  VMBundle.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/3.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

struct VMBundle {
    var url: URL
    
    var diskImageURL: URL { url.appendingPathComponent("Disk.img") }
    var efiVariableStoreURL: URL { url.appendingPathComponent("NVRAM") }
    var configURL: URL { url.appendingPathComponent("Info.json") }
    
    var needInstall: Bool { !FileManager.default.fileExists(atPath: diskImageURL.path) }
    
    init(_ url: URL) {
        self.url = url
    }
    
    // MARK: Config
    func loadConfig() -> VMConfig? {
        do {
            let jsonData = try Data(contentsOf: configURL, options: .mappedIfSafe)
            let config = try JSONDecoder().decode(VMConfig.self, from: jsonData)
            config.bundlePath = url.path
            return config
        } catch {
            print("Failed to load config:\(error)")
        }
        
        return nil
    }
    
    func save(config: VMConfig) throws {
        let jsonData = try JSONEncoder().encode(config)
        try jsonData.write(to: configURL, options: [.atomicWrite])
    }
}
