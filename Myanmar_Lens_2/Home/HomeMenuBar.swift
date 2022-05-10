//
//  HomeMenuBar.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 10/5/22.
//

import SwiftUI

struct HomeMenuBar: View {
    
    @StateObject private var viewModel = HomeMenuBarViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: XIcon.Icon.a_magnify.systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .tapToPresent(TextTranslateViewController(), .FullScreen)
            HStack(alignment: .bottom) {
                Image(systemName: XIcon.Icon.folder_circle_fill.systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .tapToPresent(DocumentPicker(item: $viewModel.pickedItem))
                Image(systemName: XIcon.Icon.camera_circle_fill.systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .tapToPresent(CameraOCRViewController(), .FullScreen)
                Image(systemName: XIcon.Icon.photo_circle_fill.systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .tapToPresent(SystemImagePicker(item: $viewModel.pickedItem)) {}
            }
            
            Image(systemName: XIcon.Icon.mic_fill.systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .tapToPresent(CameraOCRViewController(), .FullScreen)
        }
        .fullScreenCover(item: $viewModel.pickedItem) {
            PickedItemHostView(item: $0)
        }
        
    }
    
}

final class HomeMenuBarViewModel: ObservableObject {
    @Published var pickedItem: PickedItem?
}
