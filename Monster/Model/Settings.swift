//
//  Settings.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/4.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import SwiftUI

struct Settings {
    
    @AppStorage("vmDirectory")
    static var vmDirectory = FileManager.documentDirectory
    
}
