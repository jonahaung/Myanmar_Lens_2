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
    
    @Published var soruceLanguage = NLLanguage.english
    @Published var targetLanguage = NLLanguage.burmese
    
    private init() { }
    
    func cached(source string: String) async -> String? {
        Translate.find(from: string, toLanguage: targetLanguage)
    }
    
    func fetch(soruce string: String) async -> String? {
        return await translator.translate(text: string, from: soruceLanguage, to: targetLanguage)
    }
    
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
}
