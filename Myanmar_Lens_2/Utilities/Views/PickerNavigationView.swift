//
//  PickerNavigationView.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 25/3/22.
//

import SwiftUI

struct PickerNavigationView<Content: View>: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        NavigationView {
            content()
                .navigationBarItems(leading: Leading())
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    private func Leading() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
}
