//
//  VideoPreviewView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//


import AVFoundation
import UIKit

class CameraOCRPreviewView: UIView {
    
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var panGesture: UILongPressGestureRecognizer?
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    let quadView: QuadrilateralView = {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(QuadrilateralView())
    
    let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    var captureSession: AVCaptureSession? {
        didSet {
            previewLayer.session = captureSession
        }
    }
    
    private var previousPanPosition: CGPoint?
    private var closestCorner: CornerPosition?
    private var regionOfInterestTransform = CGAffineTransform.identity
    private var isActive = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        quadView.frame = bounds
        addSubview(imageView)
        addSubview(quadView)
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layerRect = previewLayer.layerRectConverted(fromMetadataOutputRect: .init(x: 0, y: 0, width: 1, height: 1))
        let layerRectScaleTransform = CGAffineTransform(scaleX: layerRect.width, y: -layerRect.height)
        let layerRectTranslateTransform = CGAffineTransform(translationX: layerRect.minX, y: layerRect.maxY)
        regionOfInterestTransform = layerRectScaleTransform.concatenating(layerRectTranslateTransform)
        imageView.frame = previewLayer.bounds
    }
    
    var regionOfInterest: CGRect {
        quadView.getQuadFrame().applying(regionOfInterestTransform.inverted()).intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
}

extension CameraOCRPreviewView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.panGesture else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        let location = gestureRecognizer.location(in: self)
        return captureSession?.isRunning == true && isActive && quadView.getQuadFrame().intersects(location.surroundingSquare(withSize: CGSize(width: 100, height: 100))) && super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    private func setupGestureRecognizer() {
        panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture?.minimumPressDuration = 0
        panGesture?.delegate = self
        addGestureRecognizer(panGesture!)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        let drawnQuad = quadView.viewQuad
        switch gesture.state {
        case .began:
            break
        case .changed:
            let position = gesture.location(in: quadView)
            let previousPanPosition = self.previousPanPosition ?? position
            let cornorPosition = self.closestCorner ?? position.closestCornerFrom(quad: drawnQuad)
            let offset = CGAffineTransform(translationX: position.x - previousPanPosition.x, y: position.y - previousPanPosition.y)
            let cornerView = quadView.cornerViewForCornerPosition(position: cornorPosition)
            let draggedCornerViewCenter = cornerView.center.applying(offset)
            quadView.moveCorner(cornerView: cornerView, atPoint: draggedCornerViewCenter)
            
            self.previousPanPosition = position
            self.closestCorner = cornorPosition
            quadView.highlightCornerAtPosition(position: cornorPosition, with: UIImage())
        case .ended:
            previousPanPosition = nil
            closestCorner = nil
            quadView.resetHighlightedCornerViews()
            
        default:
            break
        }
    }
    
    func setActive(isActive: Bool) {
        
        previewLayer.videoGravity = isActive ? .resizeAspectFill : .resizeAspect
        self.isActive = isActive
        imageView.isHidden = !isActive
        setNeedsLayout()
        quadView.display(textQuads: [])
        
    }
    
    func getQuadFrame() -> CGRect {
        quadView.getQuadFrame()
    }
}

extension CameraOCRPreviewView {
    
    func textsAffineTransform() -> CGAffineTransform {
        let regionOfInterestBounds = CGRect(origin: .zero, size: quadView.getQuadFrame().size)
        let regionViewScaleTransform = CGAffineTransform(scaleX: regionOfInterestBounds.width, y: -regionOfInterestBounds.height)
        let regionViewTranslateTransform = CGAffineTransform(translationX: 0, y: regionOfInterestBounds.height)
        return regionViewScaleTransform.concatenating(regionViewTranslateTransform)
    }
    
    func display(textQuads: [TextQuad]) {
        let color = imageView.colorOfPoint(point: CGPoint(x: imageView.frame.midX, y: imageView.frame.midY))
        textQuads.forEach{ $0.updateBackgroundColor(color: color )}
        quadView.display(textQuads: textQuads)
    }
}

import SwiftUI

extension CameraOCRPreviewView {
    
    struct SwiftUIView: UIViewRepresentable {
        let viewModel: CameraOCRViewModel
        func makeUIView(context: Context) -> CameraOCRPreviewView {
            let view = CameraOCRPreviewView()
            view.captureSession = viewModel.session
            viewModel.configure(view: view)
            return view
        }
        func updateUIView(_ uiView: CameraOCRPreviewView, context: Context) {}
    }
}
