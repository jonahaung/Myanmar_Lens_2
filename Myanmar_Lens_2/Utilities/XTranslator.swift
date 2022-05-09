//
//  XTranslator.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 26/4/22.
//

import Foundation
import Translator
import NaturalLanguage

class XTranslator {
    
    static let shared = XTranslator()
    private let translator = Translator()
    private init() { }
    
    func translate(soruce string: String) async -> String? {
        let source = string.nlLanguage
        if source == .undetermined {
            return string
        }
        let target = XDefaults.shared.targetLanguage
        if source == target {
            return string
        }
        if let cached = Translate.find(from: string, toLanguage: target) {
            return cached
        }
        if let fetched = await translator.translate(text: string, from: source, to: target) {
            Translate.createIfNeeded(source: string, sourceLanguage: source, target: fetched, targetLanguage: target)
            return fetched
        }
        return string
    }
    
    func save(souce string: String) async {
        await _ = translate(soruce: string)
    }
}

private extension String {
    var nlLanguage: NLLanguage { NLLanguage(rawValue: self.languageString ?? "en")}
}
