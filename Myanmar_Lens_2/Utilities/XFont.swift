//
//  XFont.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct XFont {
    
    enum MyanmarFont: String, CustomStringConvertible {
        var description: String { rawValue.replacingOccurrences(of: "_", with: "-")}
        case MyanmarSansPro
    }
    
    static func uiFont(for text: String, with size: CGFloat) -> UIFont {
        return text.isMyanar ? UIFont(name: MyanmarFont.MyanmarSansPro.rawValue, size: size)! : UIFont.systemFont(ofSize: size, weight: .regular)
    }
}

extension UIFont {
    var font: Font {
        .init(self)
    }
}
