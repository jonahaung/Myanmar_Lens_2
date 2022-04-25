//
//  ViewTextReconizable.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 26/4/22.
//

import Vision


protocol ViewTextReconizable {
    func makeTextQuads(results: [VNRecognizedTextObservation]) -> [TextQuad]
    func display(textQuads: [TextQuad])
}
