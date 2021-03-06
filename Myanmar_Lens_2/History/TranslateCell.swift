//
//  TranslateCell.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct TranslateCell: View {
    
    @EnvironmentObject private var translate: Translate
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(translate.from ?? "")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                Button {
                    translate.isFavourite.toggle()
                    translate.objectWillChange.send()
                } label: {
                    XIcon(translate.isFavourite ? .heart_fill : .heart)
                }
                .accentColor(translate.isFavourite ? .pink : .secondary)
                .buttonStyle(.borderless)
            }
            HStack {
                XIcon(.globe_asia_australia_fill)
                    .foregroundStyle(.tertiary)
                Text(translate.to!)
                    .font(Font.custom(XFont.MyanmarFont.MyanmarSansPro.rawValue, size: 17))
                    .foregroundColor(.secondary)
            }
        }
        
    }
}
