//
//  TranslateCell.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct TranslateCell: View {
    
    @State var translate: Translate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(translate.from!.capitalized)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            Text(translate.to!)
                .font(Font.custom(XFont.MyanmarFont.MyanmarSansPro.rawValue, size: 17))
                .foregroundColor(.secondary)
        }
        
    }
}
