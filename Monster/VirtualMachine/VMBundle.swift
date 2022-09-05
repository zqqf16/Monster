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
    
    var diskImageExists: Bool { FileManager.default.fileExists(atPath: diskImageURL.path) }
    var bundleDirectoryExists: Bool { FileManager.default.directoryExists(at: url) }
    
    init(_ url: URL) {
        self.url = url
    }
    
    init(_ config: VMConfig) {
        let bundleURL: URL
        if let bundlePath = config.bundlePath {
            bundleURL = URL(filePath: bundlePath)
        } else {
            bundleURL = Settings.vmDirectory.appendingPathComponent(config.name).appendingPathExtension("vm")
        }
        
        self.url = bundleURL
    }
    
    func prepareBundleDirectory() throws {
        if !bundleDirectoryExists {
            debugPrint("Create bundle directory: \(url.path)")
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        }
    }
    
    func prepareDiskImage(with size: StorageSize) throws {
        let diskImagePath = diskImageURL.path
        
        if !diskImageExists {
            debugPrint("Disk image does not exist: \(diskImagePath)")
            if !FileManager.default.createFile(atPath: diskImageURL.path, contents: nil, attributes: nil) {
                print("Failed to create disk image: \(diskImagePath)")
                throw VMError.fileCreationFailed(diskImagePath)
            }
        }
        
        let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: diskImagePath))
        try fileHandle.truncate(atOffset: size.bytes)
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
