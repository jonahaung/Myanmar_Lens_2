//
//  ShapeLayer.swift
//  OCRKeyboardCamera
//
//  Created by Aung Ko Min on 24/4/22.
//

import UIKit

class ShapeLayer: CAShapeLayer {
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    init(quad: Quadrilateral) {
        super.init()
        fillColor = UIColor(white: 0.2, alpha: 0.9).cgColor
        path = quad.path.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
