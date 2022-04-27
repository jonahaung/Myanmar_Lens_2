//
//  ObjectTracker.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 7/4/22.
//

import Foundation

class StringTracker {
    
    private var frameIndex: Int64 = 0

    typealias StringObservation = (lastSeen: Int64, count: Int64)
    
    private var seenStrings = [String: StringObservation]()
    private var bestCount = Int64(0)
    private var bestString = ""
    var limit = 20

    func logFrame(strings: [String]) {
        for string in strings {
            if seenStrings[string] == nil {
                seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
            }
            seenStrings[string]?.lastSeen = frameIndex
            seenStrings[string]?.count += 1
        }
    
        var obsoleteStrings = [String]()

        // Go through strings and prune any that have not been seen in while.
        // Also find the (non-pruned) string with the greatest count.
        for (string, obs) in seenStrings {
            // Remove previously seen text after 30 frames (~1s).
            if obs.lastSeen < frameIndex - 30 {
                obsoleteStrings.append(string)
            }
            
            // Find the string with the greatest count.
            let count = obs.count
            if !obsoleteStrings.contains(string) && count > bestCount {
                bestCount = Int64(count)
                bestString = string
            }
        }
        // Remove old strings.
        for string in obsoleteStrings {
            seenStrings.removeValue(forKey: string)
        }
        
        frameIndex += 1
    }
    
    func getStableString() -> String? {
        // Require the recognizer to see the same string at least 10 times.
        if bestCount >= limit {
            return bestString
        } else {
            return nil
        }
    }
    
    func reset() {
        seenStrings.removeAll()
        bestCount = 0
        bestString = ""
    }
    func reset(string: String) {
        XCache.OCR.stableStrings.insert(string)
        seenStrings.removeValue(forKey: string)
        bestCount = 0
        bestString = ""
    }
    
    func isCachedStable(_ string: String) -> Bool {
        XCache.OCR.stableStrings.contains(string)
    }
}
