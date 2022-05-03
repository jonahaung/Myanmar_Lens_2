//
//  ShapeLayerView.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 12/4/22.
//

import SwiftUI
import AVFoundation

class ImageOCRView: UIView {
    
    struct Constants {
        static let selectionColor = UIColor.tintColor.withAlphaComponent(0.5).cgColor
    }
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    private let shapeLayer: CAShapeLayer = {
        $0.fillColor = nil
        $0.strokeColor = UIColor.systemYellow.cgColor
        $0.lineWidth = 2
        return $0
    }(CAShapeLayer())

    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        layer.addSublayer(shapeLayer)
        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = imageView.image else { return }
        let imageViewFrame = AVMakeRect(aspectRatio: image.size, insideRect: self.bounds)
        imageView.frame = imageViewFrame
        shapeLayer.frame = imageViewFrame
    }
    

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            shapeLayer.sublayers?.forEach{ $0.backgroundColor = nil }
        case .changed:
            let location = gesture.location(in: imageView)
            guard let layers = shapeLayer.sublayers?.filter({ $0 is CATextLayer && $0.frame.contains(location)}) as? [CATextLayer] else { return }
            layers.forEach { layer in
                layer.backgroundColor = Constants.selectionColor
            }
        case .ended:
            if let layers = shapeLayer.sublayers?.filter({ $0 is CATextLayer && $0.backgroundColor != nil }) as? [CATextLayer] {
                var text = String()
                layers.forEach { each in
                    text += each.string as! String + " "
                }
                UIPasteboard.general.string = text
            }
        default:
            break
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let first = touches.first {
            let location = first.location(in: imageView)
            if (shapeLayer.sublayers?.filter{ $0.frame.contains(location)})?.isEmpty == true {
                shapeLayer.sublayers?.forEach{ $0.backgroundColor = nil }
            }
        }
    }
}

extension ImageOCRView {
    
    func textsAffineTransform() -> CGAffineTransform {
        let imageViewFrame = imageView.frame
        let scaleT = CGAffineTransform(scaleX: imageViewFrame.width, y: -imageViewFrame.height)
        let translateT = CGAffineTransform(translationX: 0, y: imageViewFrame.height)
        return scaleT.concatenating(translateT)
    }
    
    func display(textQuads: [TextQuad]) {
        textQuads.forEach{ $0.displayShapeLayer(in: shapeLayer)}
        textQuads.forEach{ $0.displayTextLayer(in: shapeLayer)}
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
