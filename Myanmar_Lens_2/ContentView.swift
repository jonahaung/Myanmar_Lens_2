//
//  ContentView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct ContentView: View {

    @State private var items = [Translate]()
    
    var body: some View {
        NavigationView {
            List{
                ForEach(items) { translate in
                    TranslateCell(translate: translate)
                }
            }
            .navigationTitle("Myanamr Lens")
            .navigationBarItems(trailing: navBarTrailing())
            .refreshable {
                items = Translate.all()
            }
            .task {
                items = Translate.all()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func navBarTrailing() -> some View {
        HStack {
            Button("Reset") {
                Translate.deleteAll()
            }
            XIcon(.camera_fill)
                .tapToPresent(CameraView(), .FullScreen)
        }
    }
}
