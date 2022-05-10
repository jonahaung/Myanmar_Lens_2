//
//  XPicker.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 2/5/22.
//

import SwiftUI
struct XPicker: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: XPickerViewModel
    private var pickedItem: Binding<String>
    private let title: String
   
    
    init(title: String, items: [String], pickedItem: Binding<String>) {
        _viewModel = .init(wrappedValue: .init(items: items))
        self.pickedItem = pickedItem
        self.title = title
    }
    var body: some View {
        List {
            ForEach(viewModel.alphabets, id: \.self) { alphabet in
                let items = viewModel.displayItems.filter{ $0.hasPrefix(alphabet) }
                if !items.isEmpty {
                    Section(header: Text(alphabet).id(alphabet)) {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                                .background(
                                    Button(action: {
                                        pickedItem.wrappedValue = item
                                        dismiss()
                                    }, label: {
                                        Color.clear
                                    })
                                )
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .searchable(text: $viewModel.searchText)
        .task{
            viewModel.task()
        }
        
    }
}
import Combine

final class XPickerViewModel: ObservableObject {
    let alphabets = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    private let items: [String]
    @Published var searchText = String()
    
    var displayItems = [String]()
    
    private var subscriptions = Set<AnyCancellable>()
    init(items: [String]) {
        self.items = items
        $searchText
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.search(text: text)
            }
            .store(in: &subscriptions)
    }
    
    private func search(text: String) {
        if text.isWhitespace {
            displayItems = items
        }else {
            displayItems = items.filter{$0.contains(text)}
        }
    }
    
    func task() {
        displayItems = items
    }
}
