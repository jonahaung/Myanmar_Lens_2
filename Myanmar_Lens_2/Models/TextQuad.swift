//
//  TextQuad.swift
//  OCRKeyboardCamera
//
//  Created by Aung Ko Min on 24/4/22.
//

import Vision
import UIKit

struct TextQuad {

    private let textLayer: TextLayer
    private let shapeLayer: ShapeLayer
    
    let string: String
    let quad: Quadrilateral
    
    init(observation: VNRecognizedTextObservation, affineTransform: CGAffineTransform) {
        quad = Quadrilateral(rectangleObservation: observation).applying(affineTransform)
        shapeLayer = ShapeLayer(quad: quad)
        string = Translate.displayText(string: observation.string)
        let fittedRect = CGRect(origin: quad.topLeft, size: CGSize(width: quad.topRight.x - quad.topLeft.x, height: quad.topLeft.y - quad.bottomLeft.y))
        textLayer = TextLayer(string: string, rect: fittedRect)
    }
    
    init(quad: Quadrilateral, string: String) {
        self.quad = quad
        self.string = string
        shapeLayer = ShapeLayer(quad: quad)
        let fittedRect = CGRect(origin: quad.topLeft, size: CGSize(width: quad.topRight.x - quad.topLeft.x, height: quad.topLeft.y - quad.bottomLeft.y))
        textLayer = TextLayer(string: string, rect: fittedRect)
    }
    
    func displayShapeLayer(in layer: CALayer) {
        if shapeLayer.superlayer == nil {
            layer.addSublayer(shapeLayer)
        }
    }
    
    func displayTextLayer(in layer: CALayer) {
        if textLayer.superlayer == nil {
            layer.addSublayer(textLayer)
        }
    }
    
    func remove() {
        textLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
    }
    
    func setStable() {
        shapeLayer.fillColor = UIColor.black.cgColor
    }
}
