//
//  FileManager.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

extension FileManager {
    static func getFileSize(for key: FileAttributeKey) -> UInt64? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

        guard
            let lastPath = paths.last,
            let attributeDictionary = try? FileManager.default.attributesOfFileSystem(forPath: lastPath) else { return nil }

        if let size = attributeDictionary[key] as? NSNumber {
            return size.uint64Value
        } else {
            return nil
        }
    }

    static var documentDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func directoryExists(at url: URL) -> Bool {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            return false
        }

        return isDir.boolValue
    }

    static var appSupportDirectory: URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directoryURL = appSupportURL.appendingPathComponent("im.zorro.monster")
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        return directoryURL
    }
}
