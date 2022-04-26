/// Copyright (c) 2021 Razeware LLC

import SwiftUI

struct ToggleButton: View {
    
    @Binding var selected: Bool
    
    let on: XIcon.Icon
    let off: XIcon.Icon
    
    var body: some View {
        Button(action: {
            selected.toggle()
        }, label: {
            ToggleImage($selected, on, off)
        })
    }
}


struct ToggleImage: View {
    
    private let selected: Binding<Bool>
    private let on: XIcon.Icon
    private let off: XIcon.Icon
    
    init(_ selected: Binding<Bool>,_ on: XIcon.Icon,_ off: XIcon.Icon) {
        self.selected = selected
        self.on = on
        self.off = off
    }
    
    var body: some View {
        XIcon(selected.wrappedValue ? on : off)
    }
}
