//
//  VideoPreviewView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import UIKit
import AVFoundation
import Translator
import Vision

class VideoPreviewView: UIView {
    
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    
    var captureSession: AVCaptureSession? {
        didSet {
            previewLayer.session = captureSession
        }
    }
    
    private let quadView: QuadrilateralView = {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(QuadrilateralView())
    
    private var previousPanPosition: CGPoint?
    private var closestCorner: CornerPosition?
    private var textQuads = [TextQuad]()
    private let stringTracker = StringTracker()
    private var regionOfInterestTransform = CGAffineTransform.identity
    private var textRecognizerActive = false
    private let translateOperationGroup = TranslateOperationGroup()
    private var videoGravity: AVLayerVideoGravity = .resizeAspect
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        quadView.frame = bounds
        addSubview(quadView)
        setupGestureRecognizer()
        videoGravity = previewLayer.videoGravity
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
    }
    
    var regionOfInterest: CGRect {
        quadView.getQuadFrame().applying(regionOfInterestTransform.inverted()).intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
}

extension VideoPreviewView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UILongPressGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        let location = gestureRecognizer.location(in: self)
        return textRecognizerActive && quadView.getQuadFrame().intersects(location.surroundingSquare(withSize: CGSize(width: 100, height: 100)))
    }
    private func setupGestureRecognizer() {
        let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumPressDuration = 0
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
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
    
    func clearTexts() {
        textQuads.forEach{ $0.remove() }
        textQuads.removeAll()
        resetStable()
    }
    private func resetStable() {
        stringTracker.reset()
    }
    
    func setActive(isActive: Bool) {
        textRecognizerActive = isActive
        clearTexts()
        previewLayer.videoGravity = isActive ? .resizeAspectFill : videoGravity
        quadView.setActive(isActive: isActive)
        setNeedsLayout()
    }
}

extension VideoPreviewView {
    
    func displayTextBoxes(textObservations: [VNRecognizedTextObservation]) {
        textQuads.forEach{ $0.remove() }
        textQuads.removeAll()
        if textObservations.isEmpty {
            return
        }
        let regionOfInterestBounds = CGRect(origin: .zero, size: quadView.getQuadFrame().size)
        let regionViewScaleTransform = CGAffineTransform(scaleX: regionOfInterestBounds.width, y: -regionOfInterestBounds.height)
        let regionViewTranslateTransform = CGAffineTransform(translationX: 0, y: regionOfInterestBounds.height)
        let regionViewTransform = regionViewScaleTransform.concatenating(regionViewTranslateTransform)
        
        textQuads = textObservations.map{ TextQuad(observation: $0, affineTransform: regionViewTransform )}
        
        quadView.display(textQuads: textQuads)
        
        let texts = textObservations.map{ $0.string }
        stringTracker.logFrame(strings: texts)
        if let stable = stringTracker.getStableString() {
            stringTracker.reset(string: stable)
            translateOperationGroup.addIfNeeded(string: stable)
        }
    }
}

extension VNRecognizedTextObservation {
    
    var string: String {
        return topCandidates(1).first?.string ?? ""
    }
}
