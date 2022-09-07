//
//  VMError.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/3.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

public struct Failure: LocalizedError {
    public var errorDescription: String?
    public var reason: Error?

    public init(_ message: String, reason: Error? = nil) {
        self.errorDescription = message
        self.reason = reason
    }
}
