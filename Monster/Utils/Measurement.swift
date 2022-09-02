//
//  Measurement.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation

extension Int {
    var doubleValue: Double { .init(self) }

    var B: Measurement<UnitInformationStorage> { doubleValue.B }
    var kB: Measurement<UnitInformationStorage> { doubleValue.kB }
    var MB: Measurement<UnitInformationStorage> { doubleValue.MB }
    var GB: Measurement<UnitInformationStorage> { doubleValue.GB }
    var TB: Measurement<UnitInformationStorage> { doubleValue.TB }
    var PB: Measurement<UnitInformationStorage> { doubleValue.PB }
    
    var core: Measurement<CpuCoreUnit> { .init(value: Double(self), unit: .none) }
}

extension UInt64 {
    var doubleValue: Double { .init(self) }

    var B: Measurement<UnitInformationStorage> { doubleValue.B }
    var kB: Measurement<UnitInformationStorage> { doubleValue.kB }
    var MB: Measurement<UnitInformationStorage> { doubleValue.MB }
    var GB: Measurement<UnitInformationStorage> { doubleValue.GB }
    var TB: Measurement<UnitInformationStorage> { doubleValue.TB }
    var PB: Measurement<UnitInformationStorage> { doubleValue.PB }
    
    var core: Measurement<CpuCoreUnit> { .init(value: Double(self), unit: .none) }
}

extension Double {
    var B: Measurement<UnitInformationStorage> { .init(value: self, unit: .bytes) }
    var kB: Measurement<UnitInformationStorage> { .init(value: self, unit: .kilobytes) }
    var MB: Measurement<UnitInformationStorage> { .init(value: self, unit: .mebibytes) }
    var GB: Measurement<UnitInformationStorage> { .init(value: self, unit: .gibibytes) }
    var TB: Measurement<UnitInformationStorage> { .init(value: self, unit: .tebibytes) }
    var PB: Measurement<UnitInformationStorage> { .init(value: self, unit: .pebibytes) }
}

class CpuCoreUnit: Dimension {
    static let none = CpuCoreUnit(symbol: "", converter: UnitConverterLinear(coefficient: 1.0))
    static let baseUnit = none
}
