//
//  EntranceItem.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/1.
//

import SwiftUI

struct EntranceItem: View {
    @Binding var selection: Entrance?
    var entrance: Entrance
    
    var body: some View {
        Button {
            selection = entrance
        } label: {
            Label(selection: $selection, entrance: entrance)
        }
        .buttonStyle(.plain)
    }
}

private struct Label: View {
    @Binding var selection: Entrance?
    var entrance: Entrance
    @State private var isHovering = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(nsImage: entrance.image)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .font(.title)
                .foregroundStyle(shapeStyle(Color.accentColor))
            VStack(alignment: .leading) {
                Text(entrance.name)
                    .bold()
                    .foregroundStyle(shapeStyle(Color.primary))
            }
        }
        .shadow(radius: selection == entrance ? 4 : 0)
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(selection == entrance ?
                      AnyShapeStyle(Color.accentColor) :
                        AnyShapeStyle(BackgroundStyle()))
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isHovering ? Color.accentColor : .clear)
        }
        .scaleEffect(isHovering ? 1.02 : 1)
        .onHover { isHovering in
            withAnimation {
                self.isHovering = isHovering
            }
        }
    }
    
    func shapeStyle<S: ShapeStyle>(_ style: S) -> some ShapeStyle {
        if selection == entrance {
            return AnyShapeStyle(.background)
        } else {
            return AnyShapeStyle(style)
        }
    }
}

struct EntrancePickerItem_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(Entrance.allCases) {
            EntranceItem(selection: .constant(nil), entrance: $0)
            EntranceItem(selection: .constant($0), entrance: $0)
        }
    }
}
