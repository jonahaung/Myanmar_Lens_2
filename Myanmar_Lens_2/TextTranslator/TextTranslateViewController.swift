//
//  TextTranslateViewController.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI

struct TextTranslateViewController: View {
    
    @StateObject private var viewModel = TextTranslateViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            topBar()
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Divider()
                        VStack(alignment: .leading) {
                            TranslateTextView.SwiftUIView(text: $viewModel.translated, isEditable: false, isScrollEnabled: true)
                        }
                        .frame(height: geo.size.height/2)
                        Divider()
                        VStack {
                            TranslateTextView.SwiftUIView(text: $viewModel.text, isEditable: true, isScrollEnabled: true)
                            
                        }.frame(height: geo.size.height/2)
                        Divider()
                    }
                }
            }
        }
    }
    
    private func topBar() -> some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            Spacer()
            LanguageBar()
        }.padding(.horizontal)
    }
}
