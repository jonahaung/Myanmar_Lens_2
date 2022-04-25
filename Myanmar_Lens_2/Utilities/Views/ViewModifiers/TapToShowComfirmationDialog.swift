//
//  TapToShowComfirmationDialog.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 5/4/22.
//

import SwiftUI

struct TapToShowComfirmationDialogStyle: ViewModifier {
    
    @State var items: [DialogItem]
    @State private var show = false

    func body(content: Content) -> some View {
        Button {
            show = true
        } label: {
            content
        }
        .confirmationDialog("", isPresented: $show) {
            ForEach(items) {
                Button($0.title, action: $0.action)
            }
        }
    }
}

struct DialogItem: Identifiable {
    
    var id: String { title }
    
    let title: String
    let action: ( () -> Void )
}
extension View {
    func tapToShowComfirmationDialog(items: [DialogItem]) -> some View {
        ModifiedContent(content: self, modifier: TapToShowComfirmationDialogStyle(items: items))
    }
}
