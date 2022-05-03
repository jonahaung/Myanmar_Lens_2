//
//  CGImagePropertyOrientation.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 7/4/22.
//

import UIKit
import CoreGraphics
import VideoToolbox

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            assertionFailure("Unknow orientation, falling to default")
            self = .right
        }
    }
}


extension CGImage {
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let pixelBuffer = cvPixelBuffer else {
            return nil
        }
        
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(
            pixelBuffer,
            options: nil,
            imageOut: &image)
        return image
    }
}
