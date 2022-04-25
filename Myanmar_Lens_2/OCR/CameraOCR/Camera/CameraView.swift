//
//  CameraView.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import SwiftUI


struct CameraView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CameraViewModel()
    @State private var currentZoomFactor: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { reader in
            CameraPreview(session: viewModel.session, visionService: viewModel.visionService)
                .edgesIgnoringSafeArea(.all)
                .overlay(topToolbar, alignment: .top)
                .overlay(bottomToolbar, alignment: .bottom)
                .overlay(flashBlackView)
                .statusBar(hidden: true)
                .gesture(dragGesture(reader: reader))
                .task {
                    viewModel.configure()
                }
                .alert(isPresented: $viewModel.showAlertError) {
                    Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
                        viewModel.alertError.primaryAction?()
                    }))
                }
        }
    }
    
    private var flashBlackView: some View {
        Group {
            if viewModel.willCapturePhoto {
                Color.black
            }
        }
    }
    private var topToolbar: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            
            Spacer()
            Button(action: {
                viewModel.switchFlash()
            }, label: {
                Circle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(width: 45, height: 45, alignment: .center)
                    .overlay(
                        Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(.white))
                
    
            })
            .accentColor(viewModel.isFlashOn ? .yellow : .white)
        }
        .padding()
        .accentColor(.white)
    }
    
    private var bottomToolbar: some View {
        HStack {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .tapToPresent(OCRImageView(image: image), .FullScreen)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.clear)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.capturePhoto()
            }, label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
            })
            
            Spacer()
            
            Button(action: {
                viewModel.toggleTextRecognizer()
            }, label: {
                Circle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(width: 45, height: 45, alignment: .center)
                    .overlay(
                        XIcon(viewModel.textRecognizerActive ? .camera_fill : .textformat_size)
                            .foregroundColor(.white))
            })
        }
        .padding()
        .accentColor(.white)
    }
    
    private func dragGesture(reader: GeometryProxy) -> some Gesture {
        DragGesture().onChanged({ (val) in
            if abs(val.translation.height) > abs(val.translation.width) {
                let percentage: CGFloat = -(val.translation.height / reader.size.height)
                let calc = currentZoomFactor + percentage
                let zoomFactor: CGFloat = min(max(calc, 1), 5)
                currentZoomFactor = zoomFactor
                viewModel.zoom(with: zoomFactor)
            }
        })
    }
}
