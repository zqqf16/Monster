//
//  FormTextFieldStyle.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/13.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct FormTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .monospacedDigit()
            .padding(EdgeInsets(top: -8, leading: -12, bottom: -8, trailing: -4))
            .cornerRadius(4)
            .background {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(.secondary.opacity(0.2))
            }
    }
}
