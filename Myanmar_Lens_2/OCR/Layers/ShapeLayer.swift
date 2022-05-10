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
extension UIView {

    func colorOfPoint (point: CGPoint) -> UIColor{

        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var pixelData:[UInt8] = [0, 0, 0, 0]
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.translateBy(x: -point.x, y: -point.y)
        if let _context = context {
            self.layer.render(in: _context)
        }
        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)

    }

}
