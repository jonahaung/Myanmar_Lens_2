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
    private let context = CIContext()
    weak var view: CameraOCRPreviewView?
    private var textQuads = [TextQuad]()
    private var isActive = false
    private var textRequest: VNRecognizeTextRequest
    
    @Published var progress = CGFloat.zero
    @Published var alertError: AlertError?
//    private var lastFrame: CMSampleBuffer?
    
    init() {
        textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
    }
    
    func detectText(buffer: CMSampleBuffer) {
        if let buffer = buffer.imageBuffer, let roi = view?.regionOfInterest {
            textRequest.regionOfInterest = roi
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right, options: [:])
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
        guard var results = textRequest.results else { return }
        results = results.filter{ $0.confidence >= 0.4 }
        
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
    
    private func createTextQuads(results: [VNRecognizedTextObservation]) {
        if let affineTransform = view?.textsAffineTransform() {
            let textQuads = results.map{ TextQuad($0, affineTransform )}
            clear()
            view?.display(textQuads: textQuads)
            self.textQuads = textQuads
        }
    }
    
    func clear() {
        textQuads.forEach { $0.remove() }
        textQuads.removeAll()
       
    }
}

extension CameraOCR {
    
     func set(_ isActive: Bool) {
        
        self.isActive = isActive
         progress = 0
         view?.setActive(isActive: isActive)
         clear()
         stringTracker.reset()
        
    }
}

import MLKit
import MLImage

extension CameraOCR {
    
    func detectGoogle(sampleBuffer: CMSampleBuffer) {
        
        guard let imageBuffer = sampleBuffer.imageBuffer else { return }
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(fromDevicePosition: .back)
        visionImage.orientation = orientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        recognizeText(in: visionImage, width: imageWidth, height: imageHeight)
    }
    
    private func recognizeText(in image: VisionImage, width: CGFloat, height: CGFloat) {
        var recognizedText: Text
        do {
            recognizedText = try TextRecognizer.textRecognizer().results(in: image)
        } catch {
            print(error)
            return
        }
        
        weak var weakSelf = self
        DispatchQueue.main.sync {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            guard strongSelf.isActive && !recognizedText.blocks.isEmpty else {
                strongSelf.clear()
                return
            }
            var textQuads = [TextQuad]()
            for block in recognizedText.blocks {
                for line in block.lines {
                    if let points = strongSelf.convertedPoints(from: line.cornerPoints, width: width, height: height) {
                        var quad = Quadrilateral(points)
                        quad.reorganize()
                        let textQuad = TextQuad(quad, line.text)
                        textQuads.append(textQuad)
                    }
                }
            }
            
            let strings = textQuads.map{ $0.string }
            stringTracker.logFrame(strings: strings)
            if let stableString = stringTracker.getStableString() {
                stringTracker.reset(string: stableString)
                translateOperationGroup.addIfNeeded(stableString)
            }
            let stableResults = textQuads.filter { result in
                return stringTracker.isCachedStable(result.string)
            }
            strongSelf.clear()
            guard !stableResults.isEmpty else {
                strongSelf.progress = 0
                strongSelf.view?.display(textQuads: textQuads)
                strongSelf.textQuads = textQuads
                return
            }
            strongSelf.progress = CGFloat(stableResults.count) / CGFloat(textQuads.count)
            strongSelf.view?.display(textQuads: textQuads)
            strongSelf.textQuads = textQuads
        }
        
    }
    
    private func convertedPoints(
        from points: [NSValue]?,
        width: CGFloat,
        height: CGFloat
    ) -> [CGPoint]? {
        return points?.map {
            let cgPointValue = $0.cgPointValue
            let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
            let cgPoint = view!.previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)

            return cgPoint
        }
    }
    
//    private func updatePreviewOverlayViewWithLastFrame() {
//        weak var weakSelf = self
//        DispatchQueue.main.sync {
//            guard let strongSelf = weakSelf else {
//                print("Self is nil!")
//                return
//            }
//            guard strongSelf.isActive else { return }
//            guard let lastFrame = lastFrame,
//                  let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
//            else {
//                return
//            }
//            strongSelf.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
//        }
//    }
//
//    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
//        guard let imageBuffer = imageBuffer else {
//            return
//        }
//        let orientation: UIImage.Orientation = .right
//        let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
//        view?.previewOverlayView.image = image
//    }
}
