//
//  DocTranslatorViewController.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 10/5/22.
//

import SwiftUI

struct DocTranslatorViewController: View {
    
    let text: String
    @State private var translatedText = ""
    var body: some View {
        PickerNavigationView {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    Text(translatedText)
                        .font(XFont.uiFont(for: translatedText, with: UIFont.labelFontSize).font)
                    Divider()
                    Text(text)
                        .font(XFont.uiFont(for: text, with: UIFont.labelFontSize).font)
                }.padding()
            }
            .task {
                let translated = (await translate()).joined(separator: "\n")
                DispatchQueue.main.async {
                    self.translatedText = translated
                }
            }
        }
    }
    
    private func translate() async -> [String] {
        let lines = text.lines()
        
        return await withTaskGroup(of: String.self) { group in
            var results = [String]()
            results.reserveCapacity(lines.count)
            for each in lines {
                group.addTask {
                    return await XTranslator.shared.translate(soruce: each) ?? each
                }
            }
            for await string in group {
                results.append(string)
            }
            
            return results
        }
    }
}
