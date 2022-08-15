//
//  WelcomeView.swift
//  Monster
//
//  Created by zqqf16 on 2022/8/12.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var store: Store
    @ObservedObject private var vm = VirtualMachine(name: "New VM", os: .macOS, memory: 4, disk: 30, cpu: 4)
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                Text("Create a new VM")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
                
                ConfigView(vm: vm)
                Spacer()
            }

            HStack {
                Button {
                    store.showWelcome = false
                } label: {
                    Text("Cancel")
                }
                Spacer()
                Button {
                    store.append(vm: vm)
                    store.showWelcome = false
                } label: {
                    Text("Done")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .scenePadding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
