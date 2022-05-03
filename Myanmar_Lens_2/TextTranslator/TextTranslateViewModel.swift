//
//  TextTranslateViewModel.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 27/4/22.
//

import Foundation
import Combine

final class TextTranslateViewModel: ObservableObject {
    
    @Published var text = ""
    
    @Published var translated = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .filter{ $0.count > 0 }
            .sink { [weak self] text in
                self?.translate(string: text)
            }
            .store(in: &subscriptions)
    }
    
    private func translate(string: String) {
        guard string == self.text else { return }
//        XTranslator.shared.detectLanguage(string: string)
        Task {
            if let text = await XTranslator.shared.fetch(soruce: string) {
                await displayTranslatedText(text)
            } else {
                await displayTranslatedText(string)
            }
        }
    }
    
    @MainActor private func displayTranslatedText(_ string: String) {
        translated = string
    }
    
}
