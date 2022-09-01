//
//  WelcomeView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var store: Store
    @ObservedObject private var vm = VMConfig(name: "New VM", os: .macOS, memory: 4, disk: 30, cpu: 4)
    
    let steps = ["One", "Two", "Three", "Four"]
    
    @State private var selection: Entrance?

    var body: some View {
        VStack {
            Spacer()
            Text("New Virtual Machine")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .padding()
            Spacer()
            LazyVGrid(columns: columns) {
                ForEach(Entrance.allCases) { entrance in
                    EntranceItem(
                        selection: $selection,
                        entrance: entrance)
                }
            }
            Spacer()
        }
        .scenePadding()
    }
    
    var columns: [GridItem] {
        [ GridItem(.adaptive(minimum: 250), alignment: .leading) ]
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView().environmentObject(Store())
    }
}
