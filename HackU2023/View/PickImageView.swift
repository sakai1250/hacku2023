//
//  PickImageView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import UIKit

struct PickImageView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplayed = false
    @State private var isActive = false

    var body: some View {
        NavigationStack {
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                }
                Button("画像を選択") {
                    isImagePickerDisplayed = true
                }
                Button("診断を始める") {
                    isActive = true
                }
                .navigationDestination(isPresented: $isActive) {
                    LabelPredictionView(selectedImage: $selectedImage)
                }
            }
        }
        .sheet(isPresented: $isImagePickerDisplayed) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

struct PickImageView_Previews: PreviewProvider {
    static var previews: some View {
        PickImageView()
    }
}
