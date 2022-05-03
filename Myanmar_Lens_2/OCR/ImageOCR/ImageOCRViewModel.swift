//
//  TextReconizerImage.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 7/4/22.
//


import SwiftUI
import Combine

class ImageOCRViewModel: ObservableObject {
    
    let image: UIImage
    
    private let ocr = ImageOCR()
    
    @Published var isTranslating = false
    @Published var alertError: AlertError?
    @Published var activityItem: ActivityItem?
    
    
    init(image: UIImage) {
        self.image = image
        ocr.$isTranslating
            .receive(on: RunLoop.main)
            .assign(to: &$isTranslating)
        ocr.$alertError
            .receive(on: RunLoop.main)
            .assign(to: &$alertError)
    }
    
    deinit {
        print("Deinit: ImageOCRViewModel")
    }
}

extension ImageOCRViewModel {
    
    func configure(view: ImageOCRView) {
        view.image = image
        ocr.view = view
    }
    
    @MainActor func task() {
        ocr.detectText()
    }
    
    var hasChanges: Bool {
        image != ocr.view?.image
    }
    
    @MainActor func reset() {
        ocr.view?.image = image
        objectWillChange.send()
        ocr.detectText()
    }
    
    @MainActor func filter(_ mode: ImageFilterMode) {
        guard let editedImage = ocr.view?.image else { return }
        ocr.view?.image = ImageFilterer.filter(for: editedImage, with: mode)
        objectWillChange.send()
        ocr.detectText()
    }
    
}
