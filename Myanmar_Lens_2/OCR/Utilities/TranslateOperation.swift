//
//  TranslateOperation.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import Foundation
import Translator
import NaturalLanguage

final class TranslateOperation: Operation {
    
    let string: String
    private let fromLanguage: NLLanguage
    private let toLanguage: NLLanguage
    
    init(_ string: String, fromLanguage: NLLanguage, toLanguage: NLLanguage) {
        self.string = string
        self.fromLanguage = fromLanguage
        self.toLanguage = toLanguage
    }
    
    override func main() {
        if isCancelled { return }
        if !string.isWhitespace && Translate.find(from: string, toLanguage: toLanguage) == nil {
            Translator.shared.translate(text: string, from: fromLanguage, to: toLanguage) { to in
                if self.isCancelled { return }
                if let to = to {
                    Translate.createIfNeeded(from: self.string, fromLanguage: self.fromLanguage, to: to, toLanguage: self.toLanguage)
                }
            }
        }
    }
}
