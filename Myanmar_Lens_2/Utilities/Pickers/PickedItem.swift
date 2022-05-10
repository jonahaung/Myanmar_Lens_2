//
//  PickedItem.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 10/5/22.
//

import UIKit
enum PickedItem: Identifiable {
    var id: String {
        switch self {
        case .Text(let string):
            return string
        case .Image(let uIImage):
            return uIImage.description
        }
    }
    case Text(String)
    case Image(UIImage)
}
