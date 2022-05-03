//
//  CameraView.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import SwiftUI
import NaturalLanguage
import AVFoundation


struct CameraOCRViewController: View {
    
    @AppStorage(XDefaults.Constants.soruceLanguage) var sourceLanguage: String = XDefaults.shared.soruceLanguage.rawValue
    @AppStorage(XDefaults.Constants.targetLanguage) var targetLanguage: String = XDefaults.shared.targetLanguage.rawValue
    
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
                        viewModel.stopSession()
                        dismiss()
                    } label: {
                        XIcon(.power)
                    }.accentColor(.brown)
                    
                    Spacer()
                    LanguageBar()
                    Spacer()
                    Button {
                        viewModel.switchFlash()
                    } label: {
                        ToggleImage($viewModel.isFlashOn, .bolt_fill, .bolt_slash_fill)
                    }
                }
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
                    .tapToPresent(ImageOCRViewController(image: image).onAppear(perform: onAppearOCRImage).onDisappear(perform: onDisappearOCRImage), .FullScreen)
            } else {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60, alignment: .center)
                        .foregroundColor(.clear)
                    
                    if viewModel.videoOutputActive {
                        Picker("OCR Type", selection: $viewModel.liveOcrType) {
                            ForEach(CameraOCRViewModel.LiveOcrType.allCases) {
                                Text($0.rawValue)
                                    .tag($0)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    } else {
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
                            .stroke(style: StrokeStyle(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.white)
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
            }.zIndex(5)
            
            Spacer()
            
            Button {
                viewModel.toggleActiveTextRecognizer()
            } label: {
                XIcon(.a_magnify)
                    .font(.title)
            }
            .accentColor(viewModel.videoOutputActive ? .orange : .white)
            .disabled(sourceLanguage == NLLanguage.burmese.rawValue || sourceLanguage == targetLanguage)
        }
    }
    
    private func onAppearOCRImage() {
        viewModel.stopSession()
        
    }
    private func onDisappearOCRImage() {
        viewModel.startSession()
        viewModel.capturedImage = nil
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
