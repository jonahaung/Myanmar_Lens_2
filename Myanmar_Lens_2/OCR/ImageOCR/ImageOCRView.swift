//
//  ShapeLayerView.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 12/4/22.
//

import SwiftUI
import AVFoundation
import Vision

class ImageOCRView: UIView {
    
    let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    let quadView: QuadrilateralView = {
        return $0
    }(QuadrilateralView())
    
    
    private var imageViewTransform = CGAffineTransform.identity
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(quadView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = imageView.image else { return }
        let imageViewFrame = AVMakeRect(aspectRatio: image.size, insideRect: self.bounds)
        imageView.frame = imageViewFrame
        quadView.frame = imageViewFrame
        calculateTransform()
    }
    private func calculateTransform() {
        let imageViewFrame = imageView.frame
        let scaleT = CGAffineTransform(scaleX: imageViewFrame.width, y: -imageViewFrame.height)
        let translateT = CGAffineTransform(translationX: 0, y: imageViewFrame.height)
        imageViewTransform = scaleT.concatenating(translateT)
    }
}

extension ImageOCRView {
    
    func textsAffineTransform() -> CGAffineTransform {
        imageViewTransform
    }
    
    func display(textQuads: [TextQuad]) {
        quadView.display(textQuads: textQuads)
    }
}


extension ImageOCRView {
    
    struct SwiftUIView: UIViewRepresentable {
        
        let viewModel: ImageOCRViewModel
        
        func makeUIView(context: Context) -> ImageOCRView {
            let view = ImageOCRView()
            viewModel.configure(view: view)
            return view
        }
        
        func updateUIView(_ uiView: ImageOCRView, context: Context) {}
    }
}
