//
//  +VNRecognizedTextObservation.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 3/5/22.
//

import Vision

extension VNRecognizedTextObservation {
    var string: String { self.topCandidates(1).first?.string ?? "" }
}
