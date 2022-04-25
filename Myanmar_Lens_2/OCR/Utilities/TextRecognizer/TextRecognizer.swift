//
//  TextRecognizer.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 26/4/22.
//

import Vision
import UIKit
import Translator

class TextRecognizer: NSObject {
    
    internal var textRequest: VNRecognizeTextRequest!
    private let semaphore = DispatchSemaphore(value: 3)
    internal var textQuads = [TextQuad]()
    private let translator = Translator()
    
    override init() {
        super.init()
        commonInit()
    }
    
    internal func commonInit() {
        textRequest = VNRecognizeTextRequest(completionHandler: textRecognitionHandler)
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
    }
    
    private func textRecognitionHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }
        DispatchQueue.main.async {
            self.semaphore.signal()
            self.display(results: results.filter{ $0.confidence > 0.6 })
        }
    }
    
    internal func detectText(buffer: CVPixelBuffer) {
        semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
        do {
            try handler.perform([textRequest])
        } catch {
            semaphore.signal()
            print(error)
        }
    }
    
    internal func display(results: [VNRecognizedTextObservation]) {
        clearTexts()
    }
    
    internal func display(textQuads: [TextQuad]) {
        self.textQuads = textQuads
    }
    
    private func translate(textQuads: [TextQuad]) {
        semaphore.signal()
        var translatedTextQuad = [TextQuad]()
        let group = DispatchGroup()
        textQuads.forEach { each in
            group.enter()
            if let translated = Translate.find(from: each.string, toLanguage: .burmese) {
                translatedTextQuad.append(.init(quad: each.quad, string: translated))
                group.leave()
            } else {
                
                translator.translate(text: each.string.lowercased().trimmed, from: .english, to: .burmese) { translated in
                    if let translated = translated {
                        translatedTextQuad.append(.init(quad: each.quad, string: translated))
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            self.clearTexts()
            self.display(textQuads: translatedTextQuad)
        }
    }
    
    private func clearTexts() {
        textQuads.forEach{ $0.remove() }
        textQuads.removeAll()
    }
    
    func translate() {
        translate(textQuads: textQuads)
    }
}
