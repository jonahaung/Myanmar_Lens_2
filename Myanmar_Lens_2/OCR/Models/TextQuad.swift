//
//  TextQuad.swift
//  OCRKeyboardCamera
//
//  Created by Aung Ko Min on 24/4/22.
//

import Vision
import UIKit

class TextQuad {

    private lazy var textLayer = TextLayer(string: XCache.displayText(for: string), rect: quad.fittedRect)
    private lazy var shapeLayer = ShapeLayer(quad: quad)
    var string: String
    let quad: Quadrilateral
    var image: UIImage?
    var isStable = false
    
    init(_ observation: VNRecognizedTextObservation,_ affineTransform: CGAffineTransform) {
        quad = Quadrilateral(observation).applying(affineTransform)
        string = observation.string
    }
    
    init(_ quad: Quadrilateral,_ string: String) {
        self.quad = quad
        self.string = string
    }
    
    func displayShapeLayer(in layer: CALayer) {
        layer.addSublayer(shapeLayer)
        shapeLayer.setNeedsDisplay()
    }
    
    func displayTextLayer(in layer: CALayer) {
        guard isStable else { return }
        layer.addSublayer(textLayer)
        textLayer.setNeedsDisplay()
    }
    
    func remove() {
        textLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
    }
}

// MyanmarOCR
extension TextQuad {
    
    func recognizeMyanmarTexts() async {
        guard let image = image else { return }
        if let string = await MyanmarTextRecognizer.shared.detectTexts(from: image) {
            self.string = string
        }
    }
}
// Translate
extension TextQuad {
    
    func translate() async {
        if let fetched = await XTranslator.shared.translate(soruce: string) {
            string = fetched
        }
    }
    
    @MainActor func displayTranslatedText() {
        let newLayer = TextLayer(string: string, rect: quad.fittedRect)
        newLayer.backgroundColor = textLayer.backgroundColor
        newLayer.foregroundColor = textLayer.foregroundColor
        textLayer.superlayer?.replaceSublayer(textLayer, with: newLayer)
        textLayer = newLayer
    }
}

extension TextQuad {
    
     func cropImage(originalImage: UIImage, imageViewSize: CGSize) {
        let scaled = quad.scale(imageViewSize, originalImage.size)
        self.image = ImageFilterer.crop(image: originalImage, to: scaled.fittedRect)
         if let colors = self.image?.getColors(quality: .high) {
            shapeLayer.fillColor = colors.background.cgColor
             textLayer.backgroundColor = colors.background.cgColor
            textLayer.foregroundColor = colors.primary.cgColor
        }
    }
}
