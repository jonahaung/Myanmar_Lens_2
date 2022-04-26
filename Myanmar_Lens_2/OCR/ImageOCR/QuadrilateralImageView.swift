//
//  ShapeLayerView.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 12/4/22.
//

import SwiftUI
import AVFoundation
import Vision

struct QuadrilateralImageView: UIViewRepresentable {
    
    let viewModel: OCRImageViewModel
    
    func makeUIView(context: Context) -> QuadImageView {
        let view = QuadImageView()
        view.image = viewModel.image
        viewModel.textRecognizer.view = view
        return view
    }
    
    func updateUIView(_ uiView: QuadImageView, context: Context) {}
}


class QuadImageView: UIView {
    
    private let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    private let quadView: QuadrilateralView = {
        return $0
    }(QuadrilateralView())
    
    
    private var imageViewTransform = CGAffineTransform.identity
    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(quadView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = imageView.image else { return }
        let imageViewFrame = AVMakeRect(aspectRatio: image.size, insideRect: self.bounds)
        imageView.frame = imageViewFrame
        quadView.frame = imageViewFrame
        calculateTransform()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func calculateTransform() {
        let imageViewFrame = imageView.frame
        let scaleT = CGAffineTransform(scaleX: imageViewFrame.width, y: -imageViewFrame.height)
        let translateT = CGAffineTransform(translationX: 0, y: imageViewFrame.height)
        imageViewTransform = scaleT.concatenating(translateT)
    }
}

extension QuadImageView: ViewTextReconizable {
    func makeTextQuads(results: [VNRecognizedTextObservation]) -> [TextQuad] {
        calculateTransform()
        return results.map{ TextQuad.init(observation: $0, affineTransform: imageViewTransform)}
    }
    func display(textQuads: [TextQuad]) {
        quadView.display(textQuads: textQuads)
    }
}
