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
    private let ocr = CameraOCR()
    
    
    @Published var liveOcrType = CameraOCR.LiveOcrType.Apple {
        willSet {
            ocr.set(videoOutputActive, liveOcrType: newValue)
        }
    }
    @Published var capturedImage: UIImage?
    @Published var pickedItem: PickedItem?
    @Published var isFlashOn = false
    @Published var willCapturePhoto = false
    @Published var isCameraUnavailable = true
    @Published var videoOutputActive = false
    @Published var alertError: AlertError?
    @Published var progress: CGFloat = 0
    
    let videoOutputQueue = DispatchQueue(
        label: "com.jonahaung.FrameService",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)

    let session: AVCaptureSession
    private var subscriptions = Set<AnyCancellable>()
    init() {
        self.session = cameraService.session
        
        cameraService.$capturedImage
            .receive(on: RunLoop.main)
            .compactMap{$0}
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
                guard let self = self else { return }
                self.videoOutputActive = value
                self.ocr.set(value, liveOcrType: self.liveOcrType)
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
    
    @MainActor func handleCapture() {
        if videoOutputActive {
            if session.isRunning {
                cameraService.stop()
            } else {
                progress = 0
               
                cameraService.start()
            }
        } else {
            cameraService.capturePhoto()
        }
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
        cameraService.setSampleBufferDelegate(delegate: videoOutputActive ? nil : ocr, queue: videoOutputQueue)
    }
    
    func stopSession() {
        cameraService.stop()
    }
    
    func startSession() {
        cameraService.start()
    }
    
    deinit {
        print("OCRCameraViewModel")
    }
}
