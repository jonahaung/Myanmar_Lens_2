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
        .statusBar(hidden: true)
        .task {
            viewModel.task()
        }
        .alert(item: $viewModel.alertError) { alertError in
            Alert(title: Text(alertError.title), message: Text(alertError.message), dismissButton: .default(Text(alertError.primaryButtonTitle), action: {
                alertError.primaryAction?()
            }))
        }
        .activitySheet($viewModel.activityItem)
    }
    
    private func topmBar() -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                XIcon(.power)
            }.accentColor(.brown)

            Spacer()
            
            Menu {
                Button("Share Text", role: .none) {
                    viewModel.activityItem = .init(items: UIPasteboard.general.string.str)
                }
                Button("Share Image", role: .none) {
                    viewModel.activityItem = .init(items: viewModel.image)
                }
            } label: {
                XIcon(.square_and_arrow_up)
            }
        }
    }
    
    private func bottomBar() -> some View {
        HStack {
            if viewModel.hasChanges {
                Button("Reset", role: .cancel) {
                    viewModel.reset()
                }
                .disabled(!viewModel.hasChanges)
            }
            
            Spacer()
            Menu {
                ForEach(ImageFilterMode.allCases) { mode in
                    Button(mode.description, role: .none) {
                        viewModel.filter(mode)
                    }
                }
            } label: {
                XIcon(.camera_filters)
            }
            
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
