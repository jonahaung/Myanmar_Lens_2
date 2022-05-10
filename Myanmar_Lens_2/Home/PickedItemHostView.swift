//
//  PickedItemHostView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 10/5/22.
//

import SwiftUI

struct PickedItemHostView: View {
    
    let item: PickedItem
    
    var body: some View {
        switch item {
        case .Text(let string):
            DocTranslatorViewController(text: string)
        case .Image(let uIImage):
            ImageOCRViewController(image: uIImage)
        }
    }
}
