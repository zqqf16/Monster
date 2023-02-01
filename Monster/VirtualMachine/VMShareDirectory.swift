//
//  VMShareDirectory.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/14.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

struct VMShareDirectory: Codable, Identifiable, Equatable, Hashable {
    var id: String {
        url.path
    }

    var enable: Bool
    var url: URL {
        didSet {
            bookmarkData = try? url.bookmarkData(options: .withSecurityScope)
        }
    }

    var name: String { url.lastPathComponent }
    var readOnly: Bool = false
    var bookmarkData: Data?

    func restoreFileAccess() -> Bool {
        guard let bookmarkData = bookmarkData else {
            return false
        }

        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale),
              !isStale
        else {
            return false
        }

        return url.startAccessingSecurityScopedResource()
    }

    init(enable: Bool, url: URL, readOnly: Bool) {
        self.enable = enable
        self.url = url
        self.readOnly = readOnly
        bookmarkData = try? url.bookmarkData(options: .withSecurityScope)
    }
}
