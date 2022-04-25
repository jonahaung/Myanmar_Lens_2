//
//  Frame.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 9/4/22.
//

import SwiftUI

struct SizeModifier: ViewModifier {
    let size: CGSize
    func body(content: Content) -> some View {
        content
            .frame(width: size.width, height: size.height)
    }
}

extension View {
    func size(_ size: CGSize) -> some View {
        ModifiedContent(content: self, modifier: SizeModifier(size: size))
    }
}
