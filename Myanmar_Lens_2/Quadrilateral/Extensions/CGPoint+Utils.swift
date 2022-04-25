//
//  CGPoint+Utils.swift
//  WeScan
//
//  Created by Boris Emorine on 2/9/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func cartesian(withHeight height: CGFloat) -> CGPoint {
        CGPoint(x: x, y: height - y)
    }
    
    func surroundingSquare(withSize size: CGSize) -> CGRect {
        return CGRect(x: x - size.width / 2.0, y: y - size.height / 2.0, width: size.width, height: size.height)
    }
    /// Returns the distance between two points
    func distanceTo(point: CGPoint) -> CGFloat {
        return hypot((self.x - point.x), (self.y - point.y))
    }
    /// Returns the closest corner from the point
    func closestCornerFrom(quad: Quadrilateral) -> CornerPosition {
        var smallestDistance = distanceTo(point: quad.topLeft)
        var closestCorner = CornerPosition.topLeft
        
        if distanceTo(point: quad.topRight) < smallestDistance {
            smallestDistance = distanceTo(point: quad.topRight)
            closestCorner = .topRight
        }
        
        if distanceTo(point: quad.bottomRight) < smallestDistance {
            smallestDistance = distanceTo(point: quad.bottomRight)
            closestCorner = .bottomRight
        }
        
        if distanceTo(point: quad.bottomLeft) < smallestDistance {
            smallestDistance = distanceTo(point: quad.bottomLeft)
            closestCorner = .bottomLeft
        }
        
        return closestCorner
    }
    
    func closestCornerFrom(quad: Quadrilateral, except: CornerPosition) -> CornerPosition {
        
        var smallestDistance = distanceTo(point: quad.topLeft)
        var closestCorner = CornerPosition.topLeft
        
        
        if distanceTo(point: quad.topRight) < smallestDistance {
            
            if except != .topRight {
                smallestDistance = distanceTo(point: quad.topRight)
                closestCorner = .topRight
            }
            
        }
        
        if distanceTo(point: quad.bottomRight) < smallestDistance {
            if except != .bottomRight {
                smallestDistance = distanceTo(point: quad.bottomRight)
                closestCorner = .bottomRight
            }
        }
        
        if distanceTo(point: quad.bottomLeft) < smallestDistance {
            if except != .bottomLeft {
                smallestDistance = distanceTo(point: quad.bottomLeft)
                closestCorner = .bottomLeft
            }
        }
        
        return closestCorner
    }
}
