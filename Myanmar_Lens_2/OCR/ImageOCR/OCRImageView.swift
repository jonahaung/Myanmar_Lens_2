//
//  OCRImageView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct OCRImageView: View {
    
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
        .overlay(topBar, alignment: .top)
        .overlay(bottomBar, alignment: .bottom)
    }
    
    private var topBar: some View {
        HStack {
            Button("Cancel"){
                dismiss()
            }
            Spacer()
        }
        .padding()
        .accentColor(.white)
    }
    private var bottomBar: some View {
        HStack {
            
        }
        .padding()
        .accentColor(.white)
    }
}
