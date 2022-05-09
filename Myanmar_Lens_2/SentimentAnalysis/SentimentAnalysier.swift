//
//  SentimentAnalysier.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 5/5/22.
//

import Foundation
import CoreML

final class SentimentAnalysier {
    static let shared = SentimentAnalysier()
    
    private let model = MyTextClassifier_()
    
    func sentiment(from text: String, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let output = try self?.model.prediction(text: text)
                completion(output?.label)
            }catch {
                print(error)
                completion(nil)
            }
        }
    }
    
}
