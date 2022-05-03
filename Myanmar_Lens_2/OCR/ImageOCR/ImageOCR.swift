//
//  ImageOCR.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import Foundation
import Vision
import UIKit

final class ImageOCR {
    
    @Published var alertError: AlertError?
    @Published var isTranslating = false
    
    weak var view: ImageOCRView?
    private let textRequest: VNRecognizeTextRequest
    
    init() {
        textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
    }
    
    @MainActor func detectText() {
        guard let buffer = view?.image?.pixelBuffer() else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
        do {
            try handler.perform([textRequest])
            self.handleResults()
        } catch {
            self.alertError = AlertError(title: "OCR Error", message: error.localizedDescription, primaryButtonTitle: "OK")
        }
    }
    
    @MainActor private func handleResults() {
        guard let results = textRequest.results else { return }
        if results.isEmpty {
            alertError = .init(title: "No texts detected")
            return
        }
        guard let view = view, let image = view.image else { return }
        let affineTransform = view.textsAffineTransform()
        
        
        let textQuads = results.map{ TextQuad($0, affineTransform )}
        
        let imageViewSize = view.imageView.frame.size
        textQuads.forEach{ $0.cropImage(originalImage: image, imageViewSize: imageViewSize)}
        
        if XDefaults.shared.soruceLanguage == .burmese {
            handleBurmeseOCR(textQuads: textQuads)
        } else {
            handleEnglishOCR(textQuads: textQuads)
        }
    }
    
    @MainActor private func handleBurmeseOCR(textQuads: [TextQuad]) {
        guard let view = view else {
            return
        }
        isTranslating = true
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            await recognizeText(textQuads: textQuads)
            view.display(textQuads: textQuads)
            textQuads.forEach{ $0.displayTranslatedText() }
            await translate(textQuads: textQuads)
            textQuads.forEach{ $0.displayTranslatedText() }
            self.isTranslating = false
        }
    }
    @MainActor private func handleEnglishOCR(textQuads: [TextQuad]) {
        guard let view = view else {
            return
        }
        view.display(textQuads: textQuads)
        isTranslating = true
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            await translate(textQuads: textQuads)
            textQuads.forEach{ $0.displayTranslatedText() }
            self.isTranslating = false
        }
    }
    
    
    private func recognizeText(textQuads: [TextQuad]) async {
        return await withTaskGroup(of: Void.self) { group in
            for each in textQuads {
                group.addTask {
                    await each.recognizeText()
                }
            }
        }
    }
    private func translate(textQuads: [TextQuad]) async {
        return await withTaskGroup(of: Void.self) { group in
            for each in textQuads {
                group.addTask {
                    await each.translate()
                }
            }
        }
    }
}


