//
//  VideoOutputService.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import AVFoundation
import UIKit
import Vision

class VideoTextRecognizer: TextRecognizer {
    
    weak var view: VideoPreviewView?
    private var canRecognizeText = false
    
    override func detectText(buffer: CVPixelBuffer) {
        if let roi = view?.regionOfInterest {
            textRequest.regionOfInterest = roi
        }
        super.detectText(buffer: buffer)
    }
    
    override func display(results: [VNRecognizedTextObservation]) {
        super.display(results: results)
        if self.canRecognizeText {
            if let textQuads = view?.makeTextQuads(results: results) {
                self.display(textQuads: textQuads)
            }
        }
    }
    override func display(textQuads: [TextQuad]) {
        super.display(textQuads: textQuads)
        view?.display(textQuads: textQuads)
    }
}

extension VideoTextRecognizer {
    func toggle() -> Bool {
        canRecognizeText.toggle()
        view?.setActive(isActive: canRecognizeText)
        return canRecognizeText
    }
}


extension VideoTextRecognizer: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard canRecognizeText else { return }
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return}
        detectText(buffer: cvBuffer)
    }
}
