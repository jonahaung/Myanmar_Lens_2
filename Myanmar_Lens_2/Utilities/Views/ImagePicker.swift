//
//  ImagePicker.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 11/4/22.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    
    var onPick: (UIImage) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ImagePicker.UIViewControllerType, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(parent: ImagePicker){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var image = UIImage()
            if let editedImage = info[.editedImage] as? UIImage {
                image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                image = originalImage
            }
            
            DispatchQueue.main.async {
                self.parent.onPick(image)
            }
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

import PhotosUI
import SwiftUI

struct SystemImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.dismiss) private var dismiss
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
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: SystemImagePicker
        
        init(parent: SystemImagePicker) {
            self.parent = parent
        }
    
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let img = results.first, img.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
                return
            }
            
            img.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self.parent.dismiss()
                    }
                    return
                }
                
                guard let image = image as? UIImage, let filtered = ImageFilterer.adjustColor(image) else {
                    DispatchQueue.main.async {
                        self.parent.dismiss()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.parent.item = filtered
                    self.parent.dismiss()
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
