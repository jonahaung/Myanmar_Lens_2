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
    
    var soruceLanguage: NLLanguage { XDefaults.shared.soruceLanguage }
    var targetLanguage: NLLanguage { XDefaults.shared.targetLanguage }
    
    private init() { }
    
    func cached(source string: String) async -> String? {
        Translate.find(from: string, toLanguage: targetLanguage)
    }
    
    func fetch(soruce string: String) async -> String? {
        
        return await translator.translate(text: string, from: soruceLanguage, to: targetLanguage)
    }
    
//    func detectLanguage(string: String) {
//        var detectedLanguage = self.soruceLanguage
//        if let language = string.languageString, language != "und" && detectedLanguage.rawValue != language {
//            detectedLanguage = NLLanguage(rawValue: language)
//            XDefaults.shared.soruceLanguage = detectedLanguage
//            self.soruceLanguage = detectedLanguage
//        }
//        let to: NLLanguage = (detectedLanguage == targetLanguage) ? (targetLanguage == .burmese ? .english : .burmese ) : targetLanguage
//        if self.targetLanguage != to {
//            XDefaults.shared.targetLanguage = to
//            self.targetLanguage = to
//        }
//    }
    
    func saveCache(source sourceString: String, target targetString: String) async {
        Translate.createIfNeeded(source: sourceString, sourceLanguage: soruceLanguage, target: targetString, targetLanguage: targetLanguage)
    }
    
    func save(souce string: String) async {
        guard string.isWhitespace == false else { return }
        if await cached(source: string) == nil {
            if let translated = await fetch(soruce: string)?.lowercased().trimmed {
                await saveCache(source: string, target: translated)
            }
        }
    }
    
//    func updateLanguage() {
//        self.soruceLanguage = XDefaults.shared.soruceLanguage
//        self.targetLanguage = XDefaults.shared.targetLanguage
//    }
}
