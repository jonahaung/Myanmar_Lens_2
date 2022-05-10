//
//  DocumentPicker.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 25/3/22.
//

import SwiftUI
import PDFKit


struct DocumentPicker: UIViewControllerRepresentable {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var item: PickedItem?
    
    func makeCoordinator() -> DocumentPicker.Coordinator {
        return Coordinator(parent1: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item, .image, .pdf, .plainText])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: DocumentPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {
        
        var parent: DocumentPicker
        
        init(parent1: DocumentPicker){
            parent = parent1
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let url = urls[0]
            
            guard url.startAccessingSecurityScopedResource() else {
                print("can't access")
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.parent.item = .Image(image)
                } else if let pdf = PDFDocument(url: url) {
                    if let text = pdf.string {
                        self.parent.item = .Text(text)
                    }
                } else if let text = try? String(contentsOf: url, encoding: .utf8) {
                    self.parent.item = .Text(text)
                }
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.parent.dismiss()
            }
            
        }
    }
}
