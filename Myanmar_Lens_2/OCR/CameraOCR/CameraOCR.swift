//
//  VideoOutputService.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import UIKit
import Vision
import MLKit
import MLImage

class CameraOCR {
    
    private let stringTracker = StringTracker()
    private let translateOperationGroup = TranslateOperationGroup()
    private let textRequest: VNRecognizeTextRequest
    
    weak var view: CameraOCRPreviewView?
    @Published var progress = CGFloat.zero
    @Published var alertError: AlertError?
    private var lastFrame: CVImageBuffer?
    
    init() {
        textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false
    }
}

extension CameraOCR {
    func set(_ isActive: Bool) {
        progress = 0
        view?.setActive(isActive: isActive)
        stringTracker.reset()
        
    }
}

extension CameraOCR {
    private func handleTextQuads(_ textQuads: [TextQuad]) {
        let strings = textQuads.map{ $0.string }
        stringTracker.logFrame(strings: strings)
        if let stableString = stringTracker.getStableString() {
            stringTracker.reset(string: stableString)
            translateOperationGroup.addIfNeeded(stableString)
        }
        let stableResults = textQuads.filter { result in
            return stringTracker.isCachedStable(result.string)
        }
        self.progress = CGFloat(stableResults.count) / CGFloat(textQuads.count)
        self.view?.display(textQuads: textQuads)
        
    }
    private func updatePreviewOverlayViewWithLastFrame() {
        DispatchQueue.main.sync { [weak self] in
            guard let self = self,
                  let imageBuffer = self.lastFrame else { return }
            view?.imageView.image = UIUtilities.createUIImage(from: imageBuffer, orientation: UIUtilities.imageOrientation())
        }
    }
}
//Vision
extension CameraOCR {
    func detectText(buffer: CMSampleBuffer) {
        if let imageBuffer = buffer.imageBuffer, let regionOfInterest = view?.regionOfInterest {
            lastFrame = imageBuffer
            textRequest.regionOfInterest = regionOfInterest
            let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .init(UIUtilities.imageOrientation()), options: [:])
            do {
                try handler.perform([textRequest])
            } catch {
                self.alertError = AlertError(title: "OCR Error", message: error.localizedDescription, primaryButtonTitle: "OK")
                return
            }
            updatePreviewOverlayViewWithLastFrame()
            guard var results = textRequest.results else { return }
            results = results.filter{ $0.confidence >= 0.4 }
            
            if results.isEmpty {
                textRequest.cancel()
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let affineTransform = self.view?.textsAffineTransform() {
                    let textQuads = results.map{ TextQuad($0, affineTransform )}
                    self.handleTextQuads(textQuads)
                }
            }
        }
    }
}
// Google
extension CameraOCR {
    
    func detectGoogle(buffer: CMSampleBuffer) {
        guard let imageBuffer = buffer.imageBuffer else { return }
        lastFrame = imageBuffer
        let visionImage = VisionImage(buffer: buffer)
        let orientation = UIUtilities.imageOrientation(fromDevicePosition: .back)
        visionImage.orientation = orientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        let recognizedText: Text
        do {
            recognizedText = try TextRecognizer.textRecognizer(options: TextRecognizerOptions.init()).results(in: visionImage)
        } catch {
            self.alertError = AlertError(title: "OCR Error", message: error.localizedDescription, primaryButtonTitle: "OK")
            return
        }
        updatePreviewOverlayViewWithLastFrame()
        
        DispatchQueue.main.sync { [weak self] in
            guard let self = self else { return }
            var textQuads = [TextQuad]()
            for block in recognizedText.blocks {
                for line in block.lines {
                    if let points = self.convertedPoints(from: line.cornerPoints, width: imageWidth, height: imageHeight) {
                        var quad = Quadrilateral(points)
                        quad.reorganize()
                        let textQuad = TextQuad(quad, line.text)
                        textQuads.append(textQuad)
                    }
                }
            }
            handleTextQuads(textQuads)
        }
    }
    
    private func convertedPoints(from points: [NSValue]?, width: CGFloat, height: CGFloat) -> [CGPoint]? {
        return points?.map {
            let cgPointValue = $0.cgPointValue
            let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
            return view?.previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint) ?? .zero
        }
    }
}
