//
//  ImagePicker.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 11/4/22.
//

import PhotosUI
import SwiftUI

struct SystemImagePicker: UIViewControllerRepresentable {
    
    @Binding var item: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: SystemImagePicker
        
        init(parent: SystemImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let img = results.first, img.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                picker.dismiss(animated: true)
                return }
            img.itemProvider.loadObject(ofClass: UIImage.self) {[weak picker, weak self] image, error in
                guard let self = self, let picker = picker else { return }
                DispatchQueue.main.async { [weak picker, weak self] in
                    guard let self = self, let picker = picker else { return }
                    if let error = error {
                        print(error)
                        picker.dismiss(animated: true)
                        return
                    }
                    
                    guard let image = image as? UIImage, let filtered = ImageFilterer.adjustColor(image) else {
                        picker.dismiss(animated: true)
                        return
                    }
                    
                    self.parent.item = filtered
                    picker.dismiss(animated: true)
                }
            }
        }
    }
}

enum PickedItem {
    case Text(String)
    case Image(UIImage)
    case None
}
