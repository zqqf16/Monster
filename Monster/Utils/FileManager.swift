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
}
