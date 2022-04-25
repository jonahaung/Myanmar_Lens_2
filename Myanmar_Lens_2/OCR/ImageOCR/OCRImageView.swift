//
//  OCRImageView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct OCRImageView: View {
    
    @StateObject private var viewModel: OCRImageViewModel
    @Environment(\.dismiss) var dismiss
    
    init(image: UIImage) {
        _viewModel = .init(wrappedValue: .init(image: image))
    }
    
    var body: some View {
        PickerNavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    Spacer()
                    QuadrilateralImageView(viewModel: viewModel)
                        .overlay(loadingView())
                    Spacer()
                    bottomBar()
                }
            }
            .navigationBarItems(trailing: retakeButton())
            .task {
                viewModel.task()
            }
        }
        .accentColor(.white)
    }
    
    private func retakeButton() -> some View {
        Button("Retake") {
            dismiss()
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
            Button("Translate") {
                viewModel.translate()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }
    
    private func loadingView() -> some View {
        Group {
            
        }
    }
}
