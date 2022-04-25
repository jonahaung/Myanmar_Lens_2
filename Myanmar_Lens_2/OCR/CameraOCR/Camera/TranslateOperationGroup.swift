//
//  TranslateOperationGroup.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import Foundation

final class TranslateOperationGroup {
    
    private let queue: OperationQueue = {
        $0.name = "translateQueue"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    private var operations = [String: TranslateOperation]()
    
    func addIfNeeded(string: String) {
        let string = string.lowercased().trimmed
        if operations[string] == nil {
            let op = TranslateOperation(string)
            queue.addOperation(op)
            operations[string] = op
        }
    }
    
    func cancel() {
        queue.cancelAllOperations()
        operations.forEach{ $0.value.cancel() }
    }
    
    deinit {
        cancel()
    }
}
