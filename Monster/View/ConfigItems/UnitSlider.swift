//
//  UnitSlider.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/2.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct UnitSlider<UnitType>: View where UnitType: Dimension {
    @Binding var value: Measurement<UnitType>

    var range: ClosedRange<Measurement<UnitType>>
    var step: Measurement<UnitType>
    var units: [UnitType]

    @State var currentUnit: UnitType
    
    init(
        value: Binding<Measurement<UnitType>>,
        range: ClosedRange<Measurement<UnitType>>,
        step: Measurement<UnitType>? = nil,
        units: [UnitType]
    ) {
        self._value = value
        self.range = range
        if let step = step {
            self.step = step
        } else {
            self.step = (range.upperBound - range.lowerBound)/10
        }
        self.units = units
        self._currentUnit = State(initialValue: value.wrappedValue.unit)
    }

    var body: some View {
        HStack {
            Slider(value: floatValue, in: floatRange, step: floatStep)
            
            TextField("", text: stringValue)
                .frame(width: 46, alignment: .trailing)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.trailing).padding(0)
            
            Picker("", selection: $currentUnit) {
                ForEach(units) { unit in
                    Text(unit.symbol).tag(unit)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 50, alignment: .trailing)
            .opacity(units.count > 0 ? 1 : 0)
        }
    }
    
    private var floatValue: Binding<Double> {
        Binding(
            get: {
                self.value.converted(to: currentUnit).value
            },
            set: {
                self.value = Measurement(value: $0, unit: currentUnit)
            }
        )
    }
    
    private var floatRange: ClosedRange<Double> {
        range.lowerBound.converted(to: currentUnit).value ... range.upperBound.converted(to: currentUnit).value
    }
    
    private var floatStep: Double {
        self.step.converted(to: currentUnit).value
    }
    
    private var stringValue: Binding<String> {
        Binding(
            get: {
                let value = floatValue.wrappedValue
                return value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(value)
            },
            set: {
                let filtered = $0.filter { "0123456789.".contains($0) }
                if let value = Double(filtered) {
                    self.value = Measurement(value: value, unit: currentUnit)
                }
            }
        )
    }
}

struct UnitSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UnitSlider<UnitInformationStorage>(
                value: .constant(100000.MB),
                range: 1.MB...1000.MB,
                step: 100.MB,
                units: [.megabytes, .gigabytes]
            )
            UnitSlider<UnitInformationStorage>(
                value: .constant(10.GB),
                range: 1.GB...100.GB,
                units: []
            )
        }
    }
}
