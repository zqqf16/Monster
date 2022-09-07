//
//  Banner.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/6.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import SwiftUI

struct BannerView<Content> : View where Content : View {

    @ViewBuilder var contentBilder: () -> Content

    var body: some View {
        HStack {
            Spacer(minLength: 40)
            contentBilder()
                .frame(maxWidth: 320)
                .padding()
                .cornerRadius(8)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white)
                        .shadow(color: .white, radius: 2)
                }
            Spacer(minLength: 40)
        }
    }
}

struct BannerModifier<ContentView> : ViewModifier where ContentView : View {
    @ViewBuilder var contentBilder: () -> ContentView
    
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if isPresented {
                BannerView(contentBilder: contentBilder)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .offset(y: 20)
            }
        }
    }
}

extension View {
    func banner<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.modifier(BannerModifier(contentBilder: content, isPresented: isPresented))
    }
}

struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(.black)
            .frame(width: 400, height: 200)
            .banner(isPresented: .constant(true)) {
                Text("This is a banner")
            }
    }
}
