//
//  TextQuad.swift
//  OCRKeyboardCamera
//
//  Created by Aung Ko Min on 24/4/22.
//

import Vision
import UIKit

class TextQuad {

    private var textLayer: TextLayer
    private let shapeLayer: ShapeLayer
    var string: String
    let quad: Quadrilateral
    private var image: UIImage?
    
    init(_ observation: VNRecognizedTextObservation,_ affineTransform: CGAffineTransform) {
        quad = Quadrilateral(observation).applying(affineTransform)
        shapeLayer = ShapeLayer(quad: quad)
        string = observation.string
        textLayer = TextLayer(string: XCache.displayText(for: string), rect: quad.fittedRect)
    }
    
    init(_ quad: Quadrilateral,_ string: String) {
        self.quad = quad
        self.string = string
        shapeLayer = ShapeLayer(quad: quad)
        textLayer = TextLayer(string: XCache.displayText(for: string), rect: quad.fittedRect)
    }
    
    func displayShapeLayer(in layer: CALayer) {
        layer.addSublayer(shapeLayer)
        shapeLayer.setNeedsDisplay()
    }
    
    func displayTextLayer(in layer: CALayer) {
        layer.addSublayer(textLayer)
        textLayer.setNeedsDisplay()
    }
    func updateBackgroundColor(color: UIColor) {
        
        shapeLayer.fillColor = color.cgColor
        textLayer.foregroundColor = color.isLight ? UIColor.black.cgColor : UIColor.white.cgColor
    }
    func remove() {
        textLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
    }
    func update(quad: Quadrilateral) {
        textLayer.frame.origin = quad.fittedRect.origin
    }
}

// MyanmarOCR
extension TextQuad {
    
    func recognizeText() async {
        guard let image = image else { return }
        if let string = await MyanmarTextRecognizer.shared.detectTexts(from: image) {
            self.string = string
        }
    }
}
// Translate
extension TextQuad {
    
    func translate() async {
        let source = string
        if let fetched = await XTranslator.shared.translate(soruce: source) {
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
        self.image = ImageFilterer.crop(image: originalImage, to: scaled.regionRect)
        if let colors = self.image?.getColors(quality: .low) {
            shapeLayer.fillColor = colors.background.cgColor
            textLayer.foregroundColor = colors.primary.cgColor
        }
    }
}
extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
}
