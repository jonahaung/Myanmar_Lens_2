//
//  VideoOutputService.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import UIKit
import Vision

class CameraOCR {
    
    private let stringTracker = StringTracker()
    private let translateOperationGroup = TranslateOperationGroup()
    
    weak var view: CameraOCRPreviewView?
    private var textQuads = [TextQuad]()
    private var isActive = false
    private var textRequest: VNRecognizeTextRequest
    
    @Published var progress = CGFloat.zero
    @Published var alertError: AlertError?
    
    init() {
        textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
    }
    
    func detectText(buffer: CVPixelBuffer) {
        if let roi = view?.regionOfInterest {
            textRequest.regionOfInterest = roi
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
            do {
                try handler.perform([textRequest])
                self.handleResults()
            } catch {
                self.alertError = AlertError(title: "OCR Error", message: error.localizedDescription, primaryButtonTitle: "OK")
            }
        }
    }
    
    private func handleResults() {
        guard isActive else {
            textRequest.cancel()
            DispatchQueue.main.async {
                self.clear()
            }
            return
        }
        if let results = textRequest.results  {
            
            if results.isEmpty {
                textRequest.cancel()
                
                DispatchQueue.main.async {
                    self.clear()
                }
                return
            }
            let strings = results.map{ $0.string }
            stringTracker.logFrame(strings: strings)
            if let stableString = stringTracker.getStableString() {
                stringTracker.reset(string: stableString)
                translateOperationGroup.addIfNeeded(stableString)
            }
            let stableResults = results.filter { result in
                return stringTracker.isCachedStable(result.string)
            }
            guard !stableResults.isEmpty else {
                DispatchQueue.main.async {
                    self.progress = 0
                    self.createTextQuads(results: results)
                }
                return
            }
            DispatchQueue.main.async {
                self.progress = CGFloat(stableResults.count) / CGFloat(results.count)
                self.createTextQuads(results: stableResults)
            }
        }
    }
    
    private func createTextQuads(results: [VNRecognizedTextObservation]) {
        if let affineTransform = view?.textsAffineTransform() {
            let textQuads = results.map{ TextQuad($0, affineTransform )}
            view?.display(textQuads: textQuads)
            clear()
            self.textQuads = textQuads
        }
    }
    
    private func clear() {
        textQuads.forEach { $0.remove() }
        textQuads.removeAll()
    }
}

extension CameraOCR {
    
    func set(_ isActive: Bool) {
        progress = 0
        self.isActive = isActive
        view?.setActive(isActive: isActive)
        clear()
        stringTracker.reset()
    }
}


extension VNRecognizedTextObservation {
    var string: String { self.topCandidates(1).first?.string ?? "" }
}
