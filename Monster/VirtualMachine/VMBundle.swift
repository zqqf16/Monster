//
//  VMBundle.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/3.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import AppKit

struct VMBundle {
    var url: URL
    
    var diskImageURL: URL { filePath("Disk.img") }
    var efiVariableStoreURL: URL { filePath("NVRAM") }
    var hardwareModelURL: URL { filePath("HardwareModel")}
    var machineIdentifierURL: URL { filePath("MachineIdentifier")}
    var auxiliaryStorageURL: URL { filePath("AuxiliaryStorage")}
    var configURL: URL { filePath("Info.json") }
    var snapshotURL: URL { filePath("Snapshot.png")}
    
    var bundleDirectoryExists: Bool { exists(at: url) }

    var diskImageExists: Bool { exists(at: diskImageURL) }
    var hardwareModelExists: Bool { exists(at: hardwareModelURL) }
    var machineIdentifierExists: Bool { exists(at: machineIdentifierURL) }
    var auxiliaryStorageExists: Bool { exists(at: auxiliaryStorageURL) }
    var snapshotExists: Bool { exists(at: snapshotURL) }

    init(_ url: URL) {
        self.url = url
    }
        
    private static func directoryURL(with name: String) -> URL {
        AppSettings.vmDirectory.appendingPathComponent(name).appendingPathExtension("vm")
    }
    
    static func generateBundleURL(for config: VMConfig) -> URL {
        let fileManager = FileManager.default
        var counter = 0
        var url = directoryURL(with: config.name)
    
        while fileManager.directoryExists(at: url) {
            counter += 1
            url = directoryURL(with: "\(config.name) \(counter)")
        }
        
        return url
    }
    
    static func generateDirectoryName(for config: VMConfig) -> String {
        let fileManager = FileManager.default
        var counter = 0
        var name = config.name
        while fileManager.directoryExists(at: directoryURL(with: name)) {
            counter += 1
            name = "\(config.name) \(counter)"
        }
        
        return name
    }
    
    private func exists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    private func filePath(_ fileName: String) -> URL {
        url.appendingPathComponent(fileName)
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

    func loadConfig() throws -> VMConfig {
        let jsonData = try Data(contentsOf: configURL, options: .mappedIfSafe)
        var config = try JSONDecoder().decode(VMConfig.self, from: jsonData)
        config.bundleURL = url
        return config
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
    
    func loadSnapshot() -> NSImage? {
        return NSImage(contentsOf: snapshotURL)
    }

    func save(snapshot: NSImage) throws {
        guard let data = snapshot.pngData else {
            return
        }
        
        try data.write(to: snapshotURL)
    }
    
    func remove() throws {
        try FileManager.default.removeItem(at: url)
    }
}
