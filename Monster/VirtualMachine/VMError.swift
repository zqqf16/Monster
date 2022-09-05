//
//  VMError.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/3.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

enum VMError: Error {
    case bundleNotFound
    case fileCreationFailed(String)
}
