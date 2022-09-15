//
//  VMShareFolder.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/14.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

struct VMShareFolder: Codable, Identifiable, Equatable, Hashable {
    var id: String {
        url.path
    }

    var enable: Bool
    var url: URL
    var name: String { url.lastPathComponent }
    var readOnly: Bool = false
}
