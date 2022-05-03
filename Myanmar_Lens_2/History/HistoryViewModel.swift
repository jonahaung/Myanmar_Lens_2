//
//  HistoryViewModel.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 3/5/22.
//

import Foundation

final class HistoryViewModel: ObservableObject {
    
    @Published var items = [Translate]()
    
    func task() {
        items = Translate.all()
    }
}
