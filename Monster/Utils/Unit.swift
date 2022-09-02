//
//  Unit.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

extension Unit: Identifiable {
    public var id: String { self.symbol }
}
