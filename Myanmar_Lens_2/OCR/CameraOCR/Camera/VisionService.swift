//
//  VideoOutputService.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import AVFoundation
import UIKit
import Vision

class VisionService: NSObject {
    
    weak var view: VideoPreviewView?
    private var textRequest: VNRecognizeTextRequest!
    private var canRecognizeText = false
    let semaphore = DispatchSemaphore(value: 3)
    
    override init() {
        super.init()
        textRequest = VNRecognizeTextRequest(completionHandler: textRecognitionHandler)
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
    }
    
    deinit {
        print("VideoOutputService")
    }
    
    func toggle() -> Bool {
        canRecognizeText.toggle()
        view?.setActive(isActive: canRecognizeText)
        return canRecognizeText
    }
}

extension VisionService {
    
    private func textRecognitionHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }
        DispatchQueue.main.async {
            if self.canRecognizeText {
                self.view?.displayTextBoxes(textObservations: results)
            } else {
                self.view?.clearTexts()
            }
            self.semaphore.signal()
        }
    }
}

extension VisionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard canRecognizeText else { return }
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return}
        detectText(buffer: cvBuffer)
    }
    private func detectText(buffer: CVPixelBuffer) {
        guard let regionOfInterest = view?.regionOfInterest else { return }
        semaphore.wait()
        textRequest.regionOfInterest = regionOfInterest
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
        do {
            try handler.perform([textRequest])
        } catch {
            print(error)
        }
    }
}
