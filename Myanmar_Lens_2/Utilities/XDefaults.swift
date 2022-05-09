//
//  XDefaults.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import Foundation
import NaturalLanguage

class XDefaults: ObservableObject {
    
    static let shared = XDefaults()
    
    private let userDefaults = UserDefaults.standard
    
    struct Constants {
        static let soruceLanguage = "soruceLanguage"
        static let targetLanguage = "targetLanguage"
    }
    
    var soruceLanguage: NLLanguage {
        get {
            if let string = userDefaults.string(forKey: Constants.soruceLanguage) {
                return NLLanguage(string)
            }
            return .english
        } set {
            userDefaults.set(newValue.rawValue, forKey: Constants.soruceLanguage)
            XCache.clear()
            objectWillChange.send()
        }
    }
    
    var targetLanguage: NLLanguage {
        get {
            if let string = userDefaults.string(forKey: Constants.targetLanguage) {
                return NLLanguage(string)
            }
            return .burmese
        } set {
            userDefaults.set(newValue.rawValue, forKey: Constants.targetLanguage)
            XCache.clear()
            objectWillChange.send()
        }
    }
}
