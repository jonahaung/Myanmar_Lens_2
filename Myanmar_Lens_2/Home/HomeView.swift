//
//  ContentView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            TextTranslateViewController()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: navBarTrailing())
        }
        .navigationViewStyle(.stack)
    }
    
    func navBarTrailing() -> some View {
        HStack {
            XIcon(.camera_fill)
                .tapToPresent(CameraOCRViewController(), .FullScreen)
        }
    }
}
