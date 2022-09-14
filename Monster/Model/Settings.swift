//
//  AppSettings.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/4.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import SwiftUI

struct AppSettings {
    
    @AppStorage("vmDirectory")
    static var vmDirectory = FileManager.appSupportDirectory
    
    @AppStorage("deleteVMFiles")
    static var deleteVMFiles = true
}
