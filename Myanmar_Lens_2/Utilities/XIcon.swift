//
//  XIcon.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 21/3/22.
//

import SwiftUI

struct XIcon: View {
    
    enum Icon: String {
        case square_and_arrow_up, square_and_pencil, chevron_left, xmark, pencil, scribble, trash, music_note, music_note_list, music_quarternote_3, heart_fill, star, star_fill, tuningfork, music_note_house_fill, camera_viewfinder, photo_on_rectangle_fill, paintpalette, a_magnify, equal_circle, chevron_backward, chevron_down, chevron_up, textformat_size, music_note_tv, text_viewfinder, guitars, arrow_up_circle_fill, arrow_down_circle_fill, keyboard, square_and_arrow_down, delete_left_fill, power, power_circle_fill, gobackward, goforward, plus_circle_fill, hand_point_up_left_fill, textformat_abc, textformat_alt, function, empty, camera_filters, music_mic, doc_append, highlighter, magazine, calendar, lineweight, metronome, link
        
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
