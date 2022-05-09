//
//  MainTabView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 3/5/22.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    XIcon(.music_note_house_fill)
                }
            HistoryView()
                .tabItem {
                    XIcon(.heart_fill)
                }
            SettingsView()
                .tabItem {
                    XIcon(.globe_asia_australia_fill)
                }
        }
        .environmentObject(XDefaults.shared)
    }
}
