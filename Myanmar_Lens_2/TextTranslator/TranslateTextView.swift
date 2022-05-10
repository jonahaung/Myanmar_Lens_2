//
//  TranslateTextView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI

class TranslateTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        showsVerticalScrollIndicator = false
        dataDetectorTypes = .all
        keyboardDismissMode = .onDrag
        bounces = false
        isSelectable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func scrollToBottom() {
        let length = attributedText.string.utf16.count
        let range = NSMakeRange(length-1, 0)
        scrollRangeToVisible(range)
        selectedTextRange = self.textRange(from: endOfDocument, to: endOfDocument)
    }
    
}

extension TranslateTextView {
    
    struct SwiftUIView: UIViewRepresentable {
        
        @Binding var text: String
        let isEditable: Bool
        let isScrollEnabled: Bool
        
        func makeUIView(context: Context) -> TranslateTextView {
            let view = TranslateTextView()
            view.isEditable = isEditable
            view.isScrollEnabled = isScrollEnabled
            view.delegate = context.coordinator
            view.font = UIFont(name: XFont.MyanmarFont.MyanmarSansPro.rawValue, size: isEditable ? UIFont.buttonFontSize : 25)
            
            return view
        }
        
        func updateUIView(_ uiView: TranslateTextView, context: Context) {
            if isEditable && text.isEmpty && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else {
                uiView.text = text
                uiView.scrollToBottom()
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text)
        }
        
        class Coordinator: NSObject, UITextViewDelegate {
            
            private var text: Binding<String>
            
            init(text: Binding<String>) {
                self.text = text
            }
            func textViewDidChange(_ textView: UITextView) {
                text.wrappedValue = textView.text
            }
            func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                if text == "\n" && !textView.hasText {
                    textView.resignFirstResponder()
                    return false
                }
                return true
            }
        }
    }
}
