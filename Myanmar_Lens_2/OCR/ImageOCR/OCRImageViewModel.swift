//
//  TextReconizerImage.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 7/4/22.
//


import SwiftUI

class OCRImageViewModel: ObservableObject {
    
    @Published var hasChanges = false
    let textRecognizer = ImageTextRecognizer()

    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    deinit {
        print("Deinit: TextRecognizerImage")
    }
}

extension OCRImageViewModel {
    
    func task() {
        textRecognizer.detectText()
    }
    
    func reset() {
        textRecognizer.view?.image = image
        hasChanges = false
    }
    
    func filter(_ mode: ImageFilterMode) {
        guard let editedImage = textRecognizer.view?.image else { return }
        textRecognizer.view?.image = ImageFilterer.filter(for: editedImage, with: mode)
        hasChanges = true
    }
    
    @MainActor func translate() {
        textRecognizer.translate()
    }
}
