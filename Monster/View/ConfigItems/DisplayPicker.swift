//
//  DisplayPicker.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/13.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct DisplayPicker: View {
    @Binding var selected: VMDisplay

    var body: some View {
        Menu {
            ForEach(VMDisplay.presets) { preset in
                Button(preset.name) {
                    selected = preset
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .padding(0)
        .menuStyle(.borderlessButton)
        .frame(width: 32)
    }
}

struct DisplayField: View {
    @Binding var display: VMDisplay

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
            textField($display.width)
            Text("x").padding(0)
            textField($display.height)
        }
    }
    
    func textField(_ binding: Binding<Int>, aligment: Alignment = .leading) -> some View {
        TextField("", text: stringBinding(binding))
            .monospacedDigit()
            .frame(width: 60, alignment: .leading)
            .textFieldStyle(FormTextFieldStyle())
    }
    
    func stringBinding(_ origin: Binding<Int>) -> Binding<String> {
        return Binding {
            "\(origin.wrappedValue)"
        } set: {
            if let value = Int($0) {
                origin.wrappedValue = value
            }
        }
    }
}

struct DisplayPicker_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            HStack {
                Text("Display")
                Spacer()
                DisplayField(display: .constant(.default))
                DisplayPicker(selected: .constant(.default))
            }
        }
        .formStyle(.grouped)
    }
}
