//
//  CameraView.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import SwiftUI


struct CameraView: View {
    
    @StateObject private var viewModel = CameraViewModel()
    
    @State private var currentZoomFactor: CGFloat = 1.0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                CameraPreview(session: viewModel.session, visionService: viewModel.visionService)
                    .overlay(topToolbar, alignment: .top)
                    .overlay(bottomToolbar, alignment: .bottom)
                    .gesture(dragGesture(reader: reader))
                    .task {
                        viewModel.configure()
                    }
                    .alert(isPresented: $viewModel.showAlertError) {
                        Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
                            viewModel.alertError.primaryAction?()
                        }))
                    }
                    .overlay(
                        Group {
                            if viewModel.willCapturePhoto {
                                Color.black
                            }
                        }
                    )
                    
            }
        }
    }
    
    private func dragGesture(reader: GeometryProxy) -> some Gesture {
        DragGesture().onChanged({ (val) in
            //  Only accept vertical drag
            if abs(val.translation.height) > abs(val.translation.width) {
                //  Get the percentage of vertical screen space covered by drag
                let percentage: CGFloat = -(val.translation.height / reader.size.height)
                //  Calculate new zoom factor
                let calc = currentZoomFactor + percentage
                //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                let zoomFactor: CGFloat = min(max(calc, 1), 5)
                //  Store the newly calculated zoom factor
                currentZoomFactor = zoomFactor
                //  Sets the zoom factor to the capture device session
                viewModel.zoom(with: zoomFactor)
            }
        })
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
                Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
            })
            .accentColor(viewModel.isFlashOn ? .yellow : .white)
        }
        .padding()
        .accentColor(.white)
    }
    private var bottomToolbar: some View {
        HStack {
            capturedPhotoThumbnail
            
            Spacer()
            
            captureButton
            
            Spacer()
            
            flipCameraButton
        }
        .padding()
        .accentColor(.white)
    }
    private var captureButton: some View {
        Button(action: {
            viewModel.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
        })
    }
    
    private var capturedPhotoThumbnail: some View {
        Group {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
    
    private var flipCameraButton: some View {
        Button(action: {
            viewModel.toggleTextRecognizer()
        }, label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
}
