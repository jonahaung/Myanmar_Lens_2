//
//  TextTranslateViewController.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI

struct TextTranslateViewController: View {
    
    @StateObject private var viewModel = TextTranslateViewModel()
    @EnvironmentObject private var xDefaults: XDefaults
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Divider()
                    TranslateTextView.SwiftUIView(text: $viewModel.translated, isEditable: false, isScrollEnabled: true)
                        .frame(minHeight: geo.size.height/3)
                        .padding(5)
                        .overlay(outputTextViewOverlay())
                    Divider()
                    TranslateTextView.SwiftUIView(text: $viewModel.text, isEditable: true, isScrollEnabled: true)
                        .frame(height: geo.size.height/3)
                        .padding(5)
                    Divider()
                    menuBar()
                }
            }
            .navigationBarItems(leading:  LanguageBar().font(.callout))
        }
    }
    
    private func menuBar() -> some View {
        HStack {
            XIcon(.camera_viewfinder)
                .tapToPresent(CameraOCRViewController(), .FullScreen)
            XIcon(.doc_append)
            XIcon(.photo_on_rectangle)
        }
        .padding()
        .imageScale(.large)
    }
    private func outputTextViewOverlay() -> some View {
        Group {
            if viewModel.translated.isEmpty {
                Text(xDefaults.targetLanguage.localized)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
    }
    private func inputTextViewOverlay() -> some View {
        Group {
            if viewModel.text.isEmpty {
                Text(xDefaults.soruceLanguage.localized)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
