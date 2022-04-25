//
//  ContentView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            VStack {
                Text("Hello World")
            }
            .navigationTitle("Myanamr Lens")
            .navigationBarItems(trailing: navBarTrailing())
        }
    }
    
    func navBarTrailing() -> some View {
        HStack {
            Button("Reset") {
                Translate.deleteAll()
            }
            XIcon(.camera_viewfinder)
                .tapToPresent(CameraView(), .FullScreen)
        }
    }
}
