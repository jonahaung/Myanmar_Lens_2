//
//  TextLayer.swift
//  OCRKeyboardCamera
//
//  Created by Aung Ko Min on 24/4/22.
//

import UIKit

class TextLayer: CATextLayer {
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    var newText: String?
    
    init(string: String, rect: CGRect) {
        super.init()
        guard rect.isValid() else { return }
        let fontSize = rect.height * 0.7
        let font = UIFont(name: "MyanmarSansPro", size: fontSize)!
        let textSize = string.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: 150.0), options: [.usesFontLeading], attributes: [.font: font], context: nil).size
        foregroundColor = UIColor.darkText.cgColor
        self.string = string
        self.fontSize = fontSize
        self.font = font
        self.contentsScale = UIScreen.main.scale
        self.alignmentMode = .justified
        self.isWrapped = true
        self.frame.size = textSize
        
        let xScale = min(5, (rect.width/textSize.width))
        let yScale = min(5, (rect.height/textSize.height))
        
        let scaleTransform = CGAffineTransform(scaleX: xScale, y: yScale)
        self.setAffineTransform(scaleTransform)
        self.frame.origin = rect.origin
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
