//
//  ImageOCR.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import Foundation
import Vision

final class ImageOCR {
    
    weak var view: ImageOCRView?
    private var textQuads = [TextQuad]()
    private var textRequest: VNRecognizeTextRequest
    
    @Published var alertError: AlertError?
    @Published var isTranslating = false
    
    init() {
        textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
    }
    
    func detectText() {
        guard let buffer = view?.image?.pixelBuffer() else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
        do {
            try handler.perform([textRequest])
            self.handleResults()
        } catch {
            self.alertError = AlertError(title: "OCR Error", message: error.localizedDescription, primaryButtonTitle: "OK")
        }
    }
    
    private func handleResults() {
        if let results = textRequest.results  {
            if results.isEmpty {
                alertError = .init(title: "No texts detected")
                return
            }
            createTextQuads(results: results)
        }
    }
    
    private func createTextQuads(results: [VNRecognizedTextObservation]) {
        if let affineTransform = view?.textsAffineTransform() {
            let textQuads = results.map{ TextQuad($0, affineTransform )}
            view?.display(textQuads: textQuads)
            clear()
            self.textQuads = textQuads
            translate()
        }
    }
    
    private func clear() {
        textQuads.forEach { $0.remove() }
        textQuads.removeAll()
    }
    
    func translate() {
        isTranslating = true
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            await translate(textQuads: self.textQuads)
            DispatchQueue.main.async {
                self.isTranslating = false
                self.textQuads.forEach{ $0.displayUpdatedText() }
                
            }
        }
    }
    
    private func translate(textQuads: [TextQuad]) async {
        return await withTaskGroup(of: Void.self) { group in
            for each in textQuads {
                group.addTask {
                    let source = each.string.lowercased().trimmed
                    if let cached = await XTranslator.shared.cached(source: source) {
                        each.translated(cached)
                    }
                    if let fetched = await XTranslator.shared.fetch(soruce: source) {
                        await XTranslator.shared.saveCache(source: source, target: fetched)
                        each.translated(fetched)
                    }
                }
            }
        }
    }
}
