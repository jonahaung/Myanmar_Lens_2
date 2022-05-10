//
//  TextTranslateViewController.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI
import NaturalLanguage

struct TextTranslateViewController: View {
    
    @StateObject private var viewModel = TextTranslateViewModel()
    @EnvironmentObject private var xDefaults: XDefaults
    
    var body: some View {
        PickerNavigationView {
            VStack(spacing: 0) {
                Divider()
                TranslateTextView.SwiftUIView(text: $viewModel.translated, isEditable: false, isScrollEnabled: true)
                    .frame(maxHeight: .infinity)
        
                Divider()

                TranslateTextView.SwiftUIView(text: $viewModel.text, isEditable: true, isScrollEnabled: true)
                    .frame(maxHeight: .infinity)
                sourceTextViewBar
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .navigationBarItems(trailing: LanguageBar())
        }

    }
    
    private var sourceTextViewBar: some View {
        HStack {
            
            if viewModel.text.isWhitespace == false {
                Text(viewModel.detectedLanguage.localized)
                    .italic()
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Copy") {
                UIPasteboard.general.string = viewModel.translated
            }
            .disabled(viewModel.translated.isWhitespace)
            
            Button(action: {
                XTranslator.shared.save(text: viewModel.text, sourceLanguage: xDefaults.targetLanguage, target: viewModel.translated, targetLanguage: xDefaults.targetLanguage)
            }, label: {
                Text("Save")
            })
            .disabled(viewModel.translated.isWhitespace || viewModel.text.isWhitespace)
        
            Button("Clear") {
                viewModel.text = String()
                viewModel.translated = String()
            }.disabled(viewModel.text.isWhitespace)
        }.padding(5)
    }
}
