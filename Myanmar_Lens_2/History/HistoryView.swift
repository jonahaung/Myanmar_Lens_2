//
//  HistoryView.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 3/5/22.
//

import SwiftUI

struct HistoryView: View {
    
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.items) { item in
                    TranslateCell()
                        .environmentObject(item)
                }
            }
        }
        .refreshable {
            viewModel.task()
        }
        .task {
            viewModel.task()
        }
        .navigationTitle("History")
        .navigationBarItems(trailing: trailingItems)
    }
    
    private var trailingItems: some View {
        HStack {
            Button("Clear All") {
                Translate.deleteAll()
                viewModel.task()
            }
        }
    }
}
