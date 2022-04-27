//
//  TranslateOperationGroup.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import Foundation
import NaturalLanguage

final class TranslateOperationGroup {
    
    private let queue: OperationQueue = {
        $0.name = "translateQueue"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())

    
    func addIfNeeded(_ string: String) {
        let string = string.lowercased().trimmed
        if XCache.Translation.translateOperations[string] == nil {
            let op = TranslateOperation(string)
            queue.addOperation(op)
            XCache.Translation.translateOperations[string] = op
        }
    }
    
    func cancel() {
        queue.cancelAllOperations()
        XCache.Translation.translateOperations.forEach{ $0.value.cancel() }
    }
    
    deinit {
        cancel()
    }
}
