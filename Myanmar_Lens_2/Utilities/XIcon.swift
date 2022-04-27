//
//  XIcon.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 21/3/22.
//

import SwiftUI

struct XIcon: View {
    
    enum Icon: String {
        case square_and_arrow_up, chevron_right, xmark, scribble, trash, heart_fill, star, star_fill, tuningfork, music_note_house_fill, camera_viewfinder, photo_on_rectangle, paintpalette, a_magnify, equal_circle, chevron_backward, chevron_down, chevron_up, textformat_size, text_viewfinder, arrow_up_circle_fill, arrow_down_circle_fill, keyboard, square_and_arrow_down, delete_left_fill, power, poweron, poweroff, power_circle_fill, gobackward, goforward, plus_circle_fill, hand_point_up_left_fill, textformat_abc, textformat_alt, function, empty, camera_filters, doc_append, highlighter, magazine, calendar, lineweight, link, camera_fill, play_fill, pause_fill, bolt_fill, bolt_slash_fill, globe_asia_australia_fill
        
        var systemName: String {
            return self.rawValue.replacingOccurrences(of: "_", with: ".")
        }
    }
    
    private let icon: Icon
    
    init(_ icon: Icon) {
        self.icon = icon
    }
    
    var body: some View {
        Image(systemName: icon.systemName)
    }
}
