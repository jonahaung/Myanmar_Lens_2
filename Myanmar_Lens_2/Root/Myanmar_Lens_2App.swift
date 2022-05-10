//
//  Myanmar_Lens_2App.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI
@main
struct Myanmar_Lens_2App: App {
   
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .environmentObject(XDefaults.shared)
        }
    }
}
