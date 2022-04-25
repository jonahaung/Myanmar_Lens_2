//
//  CameraPreview.swift
//  SwiftCamera
//
//  Created by Rolando Rodriguez on 10/17/20.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    
    let session: AVCaptureSession
    let visionService: VideoTextRecognizer
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.captureSession = session
        visionService.view = view
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}
