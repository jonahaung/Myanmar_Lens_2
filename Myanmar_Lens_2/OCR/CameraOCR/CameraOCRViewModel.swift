//
//  CameraViewModel.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import AVFoundation
import Combine
import UIKit

final class CameraOCRViewModel: ObservableObject {
    
    private let cameraService = CameraService()
    private let frameService = CameraFrameService()
    private let ocr = CameraOCR()
    
    @Published var capturedImage: UIImage?
    @Published var isFlashOn = false
    @Published var willCapturePhoto = false
    @Published var isCameraUnavailable = true
    @Published var videoOutputActive = false
    @Published var alertError: AlertError?
    @Published var progress: CGFloat = 0
    
    var liveTranslatorAvilible: Bool { XDefaults.shared.soruceLanguage != .burmese }
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = cameraService.session
        
        cameraService.$capturedImage
            .receive(on: RunLoop.main)
            .assign(to: &$capturedImage)
        cameraService.$alertError
            .receive(on: RunLoop.main)
            .assign(to: &$alertError)
        cameraService.$flashMode
            .receive(on: RunLoop.main)
            .compactMap{ $0 == .on }
            .assign(to: &$isFlashOn)
        cameraService.$willCapturePhoto
            .receive(on: RunLoop.main)
            .assign(to: &$willCapturePhoto)
        cameraService.$isCameraUnavailable
            .receive(on: RunLoop.main)
            .assign(to: &$isCameraUnavailable)
        cameraService.$videoOutputActive
            .receive(on: RunLoop.main)
            .sink { [weak self]  value in
                self?.videoOutputActive = value
                self?.ocr.set(value)
            }
            .store(in: &subscriptions)
        frameService.$current
            .compactMap{$0}
            .sink { [weak self] (buffer) in
                self?.ocr.detectText(buffer: buffer)
            }
            .store(in: &subscriptions)
        ocr.$progress
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: &$progress)
        ocr.$alertError
            .receive(on: RunLoop.main)
            .assign(to: &$alertError)
    }
    
    func configure(view: CameraOCRPreviewView) {
        ocr.view = view
    }
    
    func task() {
        cameraService.checkForPermissions()
        cameraService.configure()
    }
    
    func handleCapture() {
        if videoOutputActive {
            if session.isRunning {
                cameraService.stop {
                    DispatchQueue.main.async {
                        self.progress = 1
                        self.captureFrame()
                    }
                }
            } else {
                cameraService.start()
                DispatchQueue.main.async {
                    self.progress = 0
                }
            }
        }else {
            cameraService.capturePhoto()
        }
    }
    func captureFrame() {
        capturedImage = ocr.createCurrentImage()
    }
    
    func flipCamera() {
        cameraService.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        cameraService.set(zoom: factor)
    }
    
    func switchFlash() {
        cameraService.flashMode = cameraService.flashMode == .on ? .off : .on
    }
    
    func toggleActiveTextRecognizer() {
        cameraService.setSampleBufferDelegate(delegate: videoOutputActive ? nil : frameService, queue: videoOutputActive ? .init(label: "") : frameService.queue)
    }
    
    func stop() {
        cameraService.stop()
    }
    func start() {
    
        cameraService.start()
    }
    
    deinit {
        print("OCRCameraViewModel")
    }
}
