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
            Menu {
                ForEach(NLLanguage.sourceLanguages, id: \.self) { language in
                    Button(language.localized, role: .none) {
                        self.soruceLanguage = language.rawValue
                    }
                }
            } label: {
                Text(NLLanguage(rawValue: soruceLanguage).localized)
            }
            XIcon(.chevron_right)
                .foregroundColor(.gray)
                .imageScale(.small)
                .font(.body)
            Menu {
                ForEach(NLLanguage.targetLanguages, id: \.self) { language in
                    Button(language.localized, role: .none) {
                        self.targetLanguage = language.rawValue
                    }
                }
            } label: {
                Text(NLLanguage(rawValue: targetLanguage).localized)
            }

        }
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
