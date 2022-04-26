//
//  OCRImageView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct ImageOCRViewController: View {
    
    @StateObject private var viewModel: ImageOCRViewModel
    @Environment(\.dismiss) var dismiss
    
    init(image: UIImage) {
        _viewModel = .init(wrappedValue: .init(image: image))
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ImageOCRView.SwiftUIView(viewModel: viewModel)
            
            loadingView()
            
            VStack(spacing: 0) {
                topmBar()
                Spacer()
                bottomBar()
            }
            .padding()
            .accentColor(.white)
        }
        .task {
            viewModel.task()
        }
        .alert(item: $viewModel.alertError) { alertError in
            Alert(title: Text(alertError.title), message: Text(alertError.message), dismissButton: .default(Text(alertError.primaryButtonTitle), action: {
                alertError.primaryAction?()
            }))
        }
    }
    
    private func topmBar() -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                XIcon(.power)
            }
            Spacer()
        }
    }
    
    private func bottomBar() -> some View {
        HStack {
            Button("Reset", role: .cancel) {
                viewModel.reset()
            }
            .disabled(!viewModel.hasChanges)
            Spacer()
            Menu {
                ForEach(ImageFilterMode.allCases) { mode in
                    Button(mode.description) {
                        viewModel.filter(mode)
                    }
                }
            } label: {
                XIcon(.camera_filters)
            }
            Spacer()
            
        }
    }
    
    private func loadingView() -> some View {
        Group {
            if viewModel.isTranslating {
                ProgressView()
            }
        }
    }
}
