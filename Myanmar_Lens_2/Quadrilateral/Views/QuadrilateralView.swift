//
//  RectangleView.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

final class QuadrilateralView: UIView {
    
    private let quadLayer: CAShapeLayer = {
        $0.fillColor = nil
//        $0.lineWidth = 3
//        $0.strokeColor = UIColor.tintColor.cgColor
        return $0
    }(CAShapeLayer())
    
    private let quadLineLayer: CAShapeLayer = {
        $0.fillColor = nil
        $0.lineWidth = 0
        $0.strokeColor = UIColor.systemYellow.cgColor
        return $0
    }(CAShapeLayer())
    
    private lazy var topLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()
    
    private lazy var topRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()
    
    private lazy var bottomRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()
    
    private lazy var bottomLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()
    
    private(set) var viewQuad = Quadrilateral(.zero)
    
    public var isSquare = true
    
    private var isHighlighted = false {
        didSet {
            guard oldValue != isHighlighted else { return }
            cornerViews(hidden: !isHighlighted)
        }
    }
    
    private let highlightedCornerViewSize = CGSize(width: 120, height: 120)
    private let cornerViewSize = CGSize(width: 15, height: 15)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topLeftCornerView)
        addSubview(topRightCornerView)
        addSubview(bottomRightCornerView)
        addSubview(bottomLeftCornerView)
        layer.addSublayer(quadLayer)
        layer.addSublayer(quadLineLayer)
        cornerViews(hidden: true)
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        quadLineLayer.frame = bounds
        if quadLineLayer.path == nil {
            let rect = bounds
            drawQuadrilateral(quad: .init(rect))
        }
        quadLayer.frame = viewQuad.regionRect
    }

    func getQuadFrame() -> CGRect {
        viewQuad.regionRect
    }
    
    func setActive(isActive: Bool) {
        quadLineLayer.lineWidth = isActive ? 3 : 0
        let rect = isActive ? CGRect(x: 10, y: bounds.height/2 - 100, width: bounds.width - 20, height: 150) : bounds.insetBy(dx: 5, dy: 5)
        let quad = Quadrilateral(rect)
        drawQuadrilateral(quad: quad)
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = 0.4
        quadLineLayer.add(pathAnimation, forKey: "path")
        quadLayer.frame = viewQuad.regionRect
    }
}

// Input

extension QuadrilateralView {
    
    func display(textQuads: [TextQuad]) {
        textQuads.forEach{ $0.displayShapeLayer(in: quadLayer)}
        textQuads.forEach{ $0.displayTextLayer(in: quadLayer )}
    }
    
    func drawQuadrilateral(quad: Quadrilateral) {
        self.viewQuad = quad
        draw(quad, animated: !isHighlighted)
        layoutCornerViews(forQuad: quad)
    }
    
    private func draw(_ quad: Quadrilateral, animated: Bool) {
        let path = quad.path
        quadLineLayer.path = path.cgPath
        let rectPath = UIBezierPath(rect: bounds)
        rectPath.usesEvenOddFillRule = true
        path.append(rectPath)
    }
}

// Gesture

extension QuadrilateralView {
    
    private func layoutCornerViews(forQuad quad: Quadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
    }
    
    func moveCorner(cornerView: EditScanCornerView, atPoint point: CGPoint) {
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)
        
        cornerView.center = validPoint
        
        let updatedQuad = update(viewQuad, withPosition: validPoint, forCorner: cornerView.position)
        drawQuadrilateral(quad: updatedQuad)
    }
    
    func highlightCornerAtPosition(position: CornerPosition, with image: UIImage) {
        
        isHighlighted = true
        
        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            return
        }
        
        let origin = CGPoint(x: cornerView.frame.origin.x - (highlightedCornerViewSize.width - cornerViewSize.width) / 2.0, y: cornerView.frame.origin.y - (highlightedCornerViewSize.height - cornerViewSize.height) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: highlightedCornerViewSize)
        cornerView.highlightWithImage(image)
    }
    
    func resetHighlightedCornerViews() {
        isHighlighted = false
        resetHighlightedCornerViews(cornerViews: [topLeftCornerView, topRightCornerView, bottomLeftCornerView, bottomRightCornerView])
    }
    
    private func resetHighlightedCornerViews(cornerViews: [EditScanCornerView]) {
        cornerViews.forEach { (cornerView) in
            resetHightlightedCornerView(cornerView: cornerView)
        }
    }
    
    private func resetHightlightedCornerView(cornerView: EditScanCornerView) {
        cornerView.reset()
        let origin = CGPoint(x: cornerView.frame.origin.x + (cornerView.frame.size.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y + (cornerView.frame.size.height - cornerViewSize.width) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: cornerViewSize)
        cornerView.setNeedsDisplay()
    }
    
    private func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point
        
        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }
        
        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }
        
        return validPoint
    }
    
    // MARK: - Convenience
    
    private func cornerViews(hidden: Bool) {
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
    }
    
    private func update(_ quad: Quadrilateral, withPosition position: CGPoint, forCorner corner: CornerPosition) -> Quadrilateral {
        var quad = quad
        
        if isSquare {
            switch corner {
            case .topLeft:
                quad.topLeft = position
                quad.topRight.y = position.y
                quad.bottomLeft.x = position.x
            case .topRight:
                quad.topRight = position
                quad.topLeft.y = position.y
                quad.bottomRight.x = position.x
            case .bottomRight:
                quad.bottomRight = position
                quad.topRight.x = position.x
                quad.bottomLeft.y = position.y
            case .bottomLeft:
                quad.bottomLeft = position
                quad.bottomRight.y = position.y
                quad.topLeft.x = position.x
            }
        } else {
            switch corner {
            case .topLeft:
                quad.topLeft = position
            case .topRight:
                quad.topRight = position
            case .bottomRight:
                quad.bottomRight = position
            case .bottomLeft:
                quad.bottomLeft = position
            }
        }
        
        return quad
    }
    
    func cornerViewForCornerPosition(position: CornerPosition) -> EditScanCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        }
    }
}
