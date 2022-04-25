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
                    VStack {
                        Text(translate.from?.capitalized ?? "")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        +
                        Text("\n")
                        +
                        Text(translate.to ?? "")
                            .font(Font.custom(XFont.MyanmarFont.MyanmarSansPro.rawValue, size: 17))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Myanamr Lens")
            .navigationBarItems(trailing: navBarTrailing())
            .task {
                items = Translate.all()
            }
        }
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
