//
//  TextTranslateViewModel.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import Foundation
import Combine
import NaturalLanguage

final class TextTranslateViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var translated = ""
    @Published var sentiment = ""
    @Published var detectedLanguage = NLLanguage.undetermined
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.translate(string: text)
//                self?.sentiment(string: text)
            }
            .store(in: &subscriptions)
    }
    
    private func translate(string: String) {
        guard string == self.text && !string.isWhitespace else {
            translated = String()
            return
        }
        detectedLanguage = NLLanguage(rawValue: string.languageString ?? "")
        Task {
            if let text = await XTranslator.shared.translate(soruce: string) {
                await displayTranslatedText(text)
            } else {
                await displayTranslatedText(string)
            }
        }
    }
    
    private func sentiment(string: String) {
        if string.isMyanar {
            SentimentAnalysier.shared.sentiment(from: string) { [weak self] completion in
                DispatchQueue.main.async {
                    if let sentiment = completion {
                        self?.sentiment = sentiment
                    }
                }
            }
        } else {
            sentiment = ""
        }
    }
    @MainActor private func displayTranslatedText(_ string: String) {
        translated = string
    }
    func task() {
        
    }
}
