//
//  Quadrilateral.swift
//  SwiftCamera
//
//  Created by Aung Ko Min on 5/4/22.
//

import UIKit
import Vision

struct Quadrilateral {
    
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
    
    init(_ observation: VNRectangleObservation) {
        self.init(topLeft: observation.topLeft, topRight: observation.topRight, bottomRight: observation.bottomRight, bottomLeft: observation.bottomLeft)
    }

    init(_ rect: CGRect) {
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        self.init(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    
    init(_ points: [CGPoint]) {
        self.init(topLeft: points[0], topRight: points[1], bottomRight: points[2], bottomLeft: points[3])
    }
}
// Getters
extension Quadrilateral {
    var corners: [CGPoint] {
        return [topLeft, topRight, bottomLeft, bottomRight]
    }
    
    var path: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()
        return path
    }
    
    var regionRect: CGRect {
        let origin = CGPoint(
            x: max(topLeft.x, bottomLeft.x),
            y: max(topLeft.y, topRight.y))
        
        let size = CGSize(
            width: max(topRight.x, bottomRight.x) - origin.x,
            height: max(bottomLeft.y, bottomRight.y) - origin.y)
        return CGRect(origin: origin, size: size)
    }
    var fittedRect: CGRect {
        CGRect(origin: topLeft, size: CGSize(width: topRight.x - topLeft.x, height: topLeft.y - bottomLeft.y))
    }
}


// Transforming
extension Quadrilateral: Transformable {
    func applying(_ transform: CGAffineTransform) -> Quadrilateral {
        Quadrilateral(topLeft: topLeft.applying(transform), topRight: topRight.applying(transform), bottomRight: bottomRight.applying(transform), bottomLeft: bottomLeft.applying(transform))
    }
    
    func toCartesian(withHeight height: CGFloat) -> Quadrilateral {
        let topLeft = self.topLeft.cartesian(withHeight: height)
        let topRight = self.topRight.cartesian(withHeight: height)
        let bottomRight = self.bottomRight.cartesian(withHeight: height)
        let bottomLeft = self.bottomLeft.cartesian(withHeight: height)
        
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    /// Reorganizes the current quadrilateal, making sure that the points are at their appropriate positions. For example, it ensures that the top left point is actually the top and left point point of the quadrilateral.
    mutating func reorganize() {
        let points = [topLeft, topRight, bottomRight, bottomLeft]
        let ySortedPoints = sortPointsByYValue(points)
        
        guard ySortedPoints.count == 4 else {
            return
        }
        let topMostPoints = Array(ySortedPoints[0..<2])
        let bottomMostPoints = Array(ySortedPoints[2..<4])
        let xSortedTopMostPoints = sortPointsByXValue(topMostPoints)
        let xSortedBottomMostPoints = sortPointsByXValue(bottomMostPoints)
        
        guard xSortedTopMostPoints.count > 1,
              xSortedBottomMostPoints.count > 1 else {
            return
        }
        
        topLeft = xSortedTopMostPoints[0]
        topRight = xSortedTopMostPoints[1]
        bottomRight = xSortedBottomMostPoints[1]
        bottomLeft = xSortedBottomMostPoints[0]
    }
    
    func scale(_ fromSize: CGSize, _ toSize: CGSize, withRotationAngle rotationAngle: CGFloat = 0.0) -> Quadrilateral {
        var invertedfromSize = fromSize
        let rotated = rotationAngle != 0.0
        
        if rotated && rotationAngle != CGFloat.pi {
            invertedfromSize = CGSize(width: fromSize.height, height: fromSize.width)
        }
        
        var transformedQuad = self
        let invertedFromSizeWidth = invertedfromSize.width == 0 ? .leastNormalMagnitude : invertedfromSize.width
        
        let scale = toSize.width / invertedFromSizeWidth
        let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
        transformedQuad = transformedQuad.applying(scaledTransform)
        
        if rotated {
            let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
            
            let fromImageBounds = CGRect(origin: .zero, size: fromSize).applying(scaledTransform).applying(rotationTransform)
            
            let toImageBounds = CGRect(origin: .zero, size: toSize)
            let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: fromImageBounds, toCenterOfRect: toImageBounds)
            
            transformedQuad = transformedQuad.applyTransforms([rotationTransform, translationTransform])
        }
        
        return transformedQuad
    }
    
    private func sortPointsByYValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.y < point2.y
        }
    }
    
    private func sortPointsByXValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.x < point2.x
        }
    }
}

extension Quadrilateral: Equatable {
    static func == (lhs: Quadrilateral, rhs: Quadrilateral) -> Bool {
        return lhs.topLeft == rhs.topLeft && lhs.topRight == rhs.topRight && lhs.bottomRight == rhs.bottomRight && lhs.bottomLeft == rhs.bottomLeft
    }
}
