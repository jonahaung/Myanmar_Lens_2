//
//  TranslateOperation.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import Foundation

final class TranslateOperation: Operation {
    
    let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    override func main() {
        if isCancelled { return }
        Task {
            if self.isCancelled { return }
            await XTranslator.shared.save(souce: string)
        }
    }
}
