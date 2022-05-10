//
//  ContentView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            
        }
        .overlay(HomeMenuBar(), alignment: .bottom)
        .navigationTitle("Myanmar Lens")
        .navigationBarItems(leading: navBarLeading(), trailing: navBarTrailing())
    }
    
    func navBarTrailing() -> some View {
        HStack {
            XIcon(.heart_fill)
                .foregroundColor(.pink)
                .tapToPush(HistoryView())
        }
    }
    func navBarLeading() -> some View {
        HStack {
            XIcon(.scribble)
                .tapToPush(SettingsView())
            
        }
    }
}
