//
//  CameraViewModel.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import AVFoundation
import Combine
import UIKit

final class CameraViewModel: ObservableObject {
    
    private let service = CameraService()
    let visionService = VisionService()
    
    @Published var capturedImage: UIImage?
    @Published var showAlertError = false
    @Published var isFlashOn = false
    @Published var willCapturePhoto = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        service.$capturedImage.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.capturedImage = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
        service.sampleBufferDelegate = visionService
    }
    
    func capturePhoto() {
        if session.isRunning {
            service.stop()
        } else {
            service.start()
        }
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
    func toggleTextRecognizer() {
        visionService.toggle()
    }
}

