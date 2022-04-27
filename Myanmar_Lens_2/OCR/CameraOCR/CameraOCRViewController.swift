//
//  CameraView.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import SwiftUI


struct CameraOCRViewController: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CameraOCRViewModel()
    @State private var currentZoomFactor: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                CameraOCRPreviewView.SwiftUIView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                    .gesture(dragGesture(reader: reader))
                
                flashBlackView()
                VStack {
                    topBar()
                    Spacer()
                    bottomBar()
                }
                .padding()
                .accentColor(.white)
                .animation(.spring())
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
        }
    }
    
    private func flashBlackView() -> some View {
        Group {
            if viewModel.willCapturePhoto {
                Color.black
            }
        }
    }
    private func topBar() -> some View {
        Group {
            if !viewModel.videoOutputActive {
                HStack {
                    Button {
                        viewModel.stop()
                        dismiss()
                    } label: {
                        XIcon(.power)
                    }
                    Spacer()
                    LanguageBar()
                    Spacer()
                    Button {
                        viewModel.switchFlash()
                    } label: {
                        ToggleImage($viewModel.isFlashOn, .bolt_fill, .bolt_slash_fill)
                    }
                }
                .transition(.scale)
            }
        }
    }
    
    private func bottomBar() -> some View {
        HStack(alignment: .bottom) {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .tapToPresent(ImageOCRViewController(image: image), .FullScreen)
            } else {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60, alignment: .center)
                        .foregroundColor(.clear)
                    
                    if !viewModel.videoOutputActive {
                        XIcon(.photo_on_rectangle)
                            .transition(.offset(x: -100))
                            .tapToPresent(SystemImagePicker(item: $viewModel.capturedImage))
                    }
                }
            }
            
            Spacer()
            
            Button {
                viewModel.handleCapture()
            } label: {
                if viewModel.videoOutputActive {
                    ZStack {
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(self.viewModel.progress, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.orange)
                            .rotationEffect(Angle(degrees: 270.0))
                            .frame(width: 60, height: 60)
                        ToggleImage($viewModel.isCameraUnavailable, .play_fill, .pause_fill)
                            .foregroundColor(.orange)
                            .font(.system(size: 25))
                    }
                    .transition(.offset(y: 150))
                } else {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .transition(.scale)
                }
            }
            
            Spacer()
            
            Button {
                viewModel.toggleActiveTextRecognizer()
            } label: {
                XIcon(.a_magnify)
                    .font(.title)
            }
            .accentColor(viewModel.videoOutputActive ? .white : .init(white: 0.4))
            .disabled(!viewModel.liveTranslatorAvilible)
        }
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
