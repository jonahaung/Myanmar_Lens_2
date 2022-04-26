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
            self.display(results: results.filter{ $0.confidence > 0.4 })
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
    
    @MainActor internal func display(results: [VNRecognizedTextObservation]) {
        clearTexts()
    }
    
    @MainActor internal func display(textQuads: [TextQuad]) {
        self.textQuads = textQuads
    }
    
    private func translate(textQuads: [TextQuad]) async -> [TextQuad] {
        return await withTaskGroup(of: TextQuad.self) { group in
            var newTextQuads = [TextQuad]()
            newTextQuads.reserveCapacity(textQuads.count)
            for each in textQuads {
                group.addTask {
                    if let translated = await Translator.shared.translate(text: each.string, from: .english, to: .burmese) {
                        return TextQuad(quad: each.quad, string: translated)
                    }
                    return each
                }
            }
            for await textQuad in group {
                newTextQuads.append(textQuad)
            }
            return newTextQuads
        }
    }
    
    @MainActor private func clearTexts() {
        textQuads.forEach{ $0.remove() }
        textQuads.removeAll()
    }
    
    @MainActor func translate() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            let translatedTextQuad = await translate(textQuads: self.textQuads)
            clearTexts()
            display(textQuads: translatedTextQuad)
        }
    }
}
