//
//  SettingsView.swift
//  Monster
//
//  Created by zqqf16 on 2023/2/3.
//  Copyright © 2023 zqqf16. All rights reserved.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppSetting(\.showDockIcon) var showDockIcon

    var body: some View {
        Form {
            Toggle("Show dock icon", isOn: $showDockIcon)
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, advanced
    }

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}
