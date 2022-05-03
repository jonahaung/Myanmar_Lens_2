//
//  TextRecognizing.swift
//  MyanmarLens2
//
//  Created by Aung Ko Min on 19/5/21.
//

import UIKit
import SwiftyTesseract

final class MyanmarTextRecognizer {

    static let shared = MyanmarTextRecognizer()
    
    private let tesseract = SwiftyTesseract(languages: [.burmese, .english], dataSource: Bundle.main, engineMode: .lstmOnly)
    
    init() {
        tesseract.preserveInterwordSpaces = true
    }
    
    func detectTexts(from image: UIImage,  _ completion: @escaping (String?) -> Void) {
        tesseract.performOCR(on: image, completionHandler: completion)
    }
    func detectTexts(from image: UIImage) async -> String? {
        return try? tesseract.performOCR(on: image).get()
    }
}
