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
    var hardwareModelURL: URL { url.appendingPathComponent("HardwareModel")}
    var machineIdentifierURL: URL { url.appendingPathComponent("MachineIdentifier")}
    var auxiliaryStorageURL: URL { url.appendingPathComponent("AuxiliaryStorage")}
    var configURL: URL { url.appendingPathComponent("Info.json") }
    
    var bundleDirectoryExists: Bool { FileManager.default.directoryExists(at: url) }

    var diskImageExists: Bool { FileManager.default.fileExists(atPath: diskImageURL.path) }
    var hardwareModelExists: Bool { FileManager.default.fileExists(atPath: hardwareModelURL.path) }
    var machineIdentifierExists: Bool { FileManager.default.fileExists(atPath: machineIdentifierURL.path) }
    var auxiliaryStorageExists: Bool { FileManager.default.fileExists(atPath: auxiliaryStorageURL.path) }

    init(_ url: URL) {
        self.url = url
    }
    
    init(_ config: VMConfig) {
        let bundleURL: URL
        if let bundlePath = config.bundlePath {
            bundleURL = URL(filePath: bundlePath)
        } else {
            let name = Self.generateDirectoryName(for: config)
            bundleURL = Self.directoryURL(with: name)
        }
        
        self.url = bundleURL
    }
    
    private static func directoryURL(with name: String) -> URL {
        AppSettings.vmDirectory.appendingPathComponent(name).appendingPathExtension("vm")
    }
    
    private static func generateDirectoryName(for config: VMConfig) -> String {
        let fileManager = FileManager.default
        var counter = 0
        var name = config.name
        while fileManager.directoryExists(at: directoryURL(with: name)) {
            counter += 1
            name = "\(config.name) \(counter)"
        }
        
        return name
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
                throw Failure("Failed to create disk image: \(diskImagePath)")
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
    
    func save(hardware: Data) throws {
        try hardware.write(to: hardwareModelURL)
    }
    
    func save(machineIdentifier: Data) throws {
        try machineIdentifier.write(to: machineIdentifierURL)
    }
    
    func remove() throws {
        try FileManager.default.removeItem(at: url)
    }
}
