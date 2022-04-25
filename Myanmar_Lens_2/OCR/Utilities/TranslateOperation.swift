//
//  TranslateOperation.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import Foundation
import Translator

final class TranslateOperation: Operation {
    
    let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    override func main() {
        if isCancelled { return }
        if !string.isWhitespace && Translate.find(string: string) == nil {
            Translator.shared.translate(text: string, from: .english, to: .burmese) { to in
                if self.isCancelled { return }
                if let to = to?.trimmed, !to.isWhitespace {
                    Translate.createIfNeeded(from: self.string, to: to)
                }
            }
        }
    }
}
