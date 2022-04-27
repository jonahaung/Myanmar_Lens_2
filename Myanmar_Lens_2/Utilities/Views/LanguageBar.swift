//
//  LanguageBar.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI
import NaturalLanguage

struct LanguageBar: View {
    
    @AppStorage(XDefaults.Constants.soruceLanguage) var soruceLanguage: String = NLLanguage.english.rawValue
    @AppStorage(XDefaults.Constants.targetLanguage) var targetLanguage: String = NLLanguage.burmese.rawValue
    
    var body: some View {
        HStack {
            Picker(selection: $soruceLanguage) {
                ForEach(NLLanguage.sourceLanguages, id: \.self) { language in
                    Text(language.localized)
                        .tag(language.rawValue)
                }
            } label: {}.labelsHidden()
            
            XIcon(.globe_asia_australia_fill)
                .foregroundColor(.gray)
                .imageScale(.small)
            
            Picker(selection: $targetLanguage) {
                ForEach(NLLanguage.targetLanguages, id: \.self) { language in
                    Text(language.localized)
                        .tag(language.rawValue)
                }
            } label: {}.labelsHidden()
        }
        .animation(nil, value: 0)
        
    }
}

extension NLLanguage {
    static var sourceLanguages: [NLLanguage] {
        [.english, .burmese]
    }
    static var targetLanguages: [NLLanguage] {
        [.english, .burmese, .simplifiedChinese, .japanese, .korean, .hindi, .thai, .tamil, .arabic, .german, .french, .spanish, .marathi]
    }
    
    var localized: String { Locale.current.localizedString(forLanguageCode: self.rawValue) ?? ""}
    
}
