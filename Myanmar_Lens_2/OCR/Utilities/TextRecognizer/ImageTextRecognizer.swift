//
//  ImageTextRecognizer.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 26/4/22.
//

import UIKit
import Vision

final class ImageTextRecognizer: TextRecognizer {
    
    weak var view: QuadImageView?
    
    func detectText() {
        if let image = view?.image, let buffer = image.pixelBuffer() {
            detectText(buffer: buffer)
        }
    }
    
    override func display(results: [VNRecognizedTextObservation]) {
        super.display(results: results)
        if let textQuads = view?.makeTextQuads(results: results), textQuads.isEmpty == false {
            display(textQuads: textQuads)
        }
    }
    override func display(textQuads: [TextQuad]) {
        super.display(textQuads: textQuads)
        view?.display(textQuads: textQuads)
    }
}
