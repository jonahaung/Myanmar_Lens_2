//
//  XCache.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import Foundation

struct XCache {
    
    struct Translation {
        static var translateOperations = [String: TranslateOperation]()
        static var translatePairs = [String: String]()
        
        static func clear() {
            translateOperations.forEach {
                $0.value.cancel()
            }
            translateOperations.removeAll()
            translatePairs.removeAll()
        }
    }
    
    struct OCR {
        static var stableStrings = Set<String>()
        static func clear() {
            stableStrings.removeAll()
        }
    }
    
    
    static func clear() {
        Translation.clear()
        OCR.clear()
    }
    
    static func displayText(for string: String) -> String {
        if let x = Translation.translatePairs[string] {
            return x
        }
        if let x = Translate.find(from: string, toLanguage: XDefaults.shared.targetLanguage) {
            Translation.translatePairs[string] = x
        }
        return string
    }
}
