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
        textLayer = TextLayer(string: string, rect: quad.fittedRect)
    }
    
    func displayShapeLayer(in layer: CALayer) {
        layer.addSublayer(shapeLayer)
        shapeLayer.setNeedsDisplay()
    }
    
    func displayTextLayer(in layer: CALayer) {
        layer.addSublayer(textLayer)
        textLayer.setNeedsDisplay()
    }
    
    func remove() {
        textLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
    }
    
    func translated(_ translatedText: String) {
        string = translatedText
    }
    func displayUpdatedText() {
        let newLayer = TextLayer(string: string, rect: quad.fittedRect)
        textLayer.superlayer?.replaceSublayer(textLayer, with: newLayer)
        textLayer = newLayer
    }
}

