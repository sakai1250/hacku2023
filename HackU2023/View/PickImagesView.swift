//
//  PickImageView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import UIKit


struct PickOneView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>
    
    @State private var selectedImages: [UIImage] = []
    @State private var selectedImagesPair: [[UIImage]] = [[]]
    @State private var imagePath: URL?
    @State private var isImagePickerDisplayed = false
    @State private var isActive = false
    @State private var isActiveHome = false
    @State private var isActiveBack = false
    @State private var isEmpty = true


    let screen: CGRect = UIScreen.main.bounds

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if !isEmpty {
                        Image("Hacku_select2")
                            .resizable()
                            .frame(maxWidth: screen.width / 0.9)
                            .frame(maxHeight: screen.height / 0.9)
                    } else {
                        Image("Hacku_select")
                            .resizable()
                            .frame(maxWidth: screen.width / 0.9)
                            .frame(maxHeight: screen.height / 0.9)
                    }
                    VStack {
                            if !isEmpty {
                                VStack {
                                    ForEach(selectedImagesPair, id: \.self) { _selectedImages in
                                        HStack {
                                            ForEach(_selectedImages, id: \.self) { image in
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                        }
                                            .padding()
                                            .background(Color.brown)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                    

                                    Button("服を選ぶ") {
                                        isImagePickerDisplayed = true
                                    }
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .frame(maxWidth: screen.width / 2)
                                        .frame(maxHeight: screen.height / 5)
                                }
                                Button("診断を始める") {
                                    isActive = true
                                    for _selectedImages in selectedImagesPair {
                                        saveImages(selectedImages: _selectedImages, imagePath: imagePath)
                                    }
                                }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .frame(maxWidth: screen.width / 2)
                                    .frame(maxHeight: screen.height / 5)
                                    .navigationDestination(isPresented: $isActive) {
                                        LabelsPredictionView(selectedImagesPair: $selectedImagesPair)
                                }
                            }
                            else {
                            Button("服を選ぶ") {
                                isImagePickerDisplayed = true
                            }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .frame(maxWidth: screen.width / 2)
                                .frame(maxHeight: screen.height / 5)
                            }
                        Button("ホームへ") {
                            isActiveBack = true
                        }
                        .padding()
                        .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .frame(maxWidth: screen.width / 2)
                        .frame(maxHeight: screen.height / 5)
                        .navigationDestination(isPresented: $isActiveBack) {
                            MainView()
                        }
                    }
                }
            }

            .sheet(isPresented: $isImagePickerDisplayed) {
                ImagePicker(selectedImages: $selectedImages)
                    .onDisappear {
                        // ImagePickerが閉じられるときにselectedImagesPairに選択された画像を追加
                        if !selectedImages.isEmpty {
                            selectedImagesPair.append(selectedImages)
                            isEmpty = false
                            selectedImages = [] // 選択された画像をリセット
                        }
                        selectedImagesPair = Array(selectedImagesPair.dropFirst()) // ここでdropFirstの結果を使用
                    }
            }
            .navigationBarBackButtonHidden(true)


//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        isActiveHome = true
//                    })
//                    {
//                        HStack {
//                            Image(systemName: "arrow.left")
//                            Text("HONE")
//                        }
//                        .navigationDestination(isPresented: $isActiveHome) {
//                            MainView()
//                        }
//                    }
//                }
//            }
        }
    }


    func saveImages(selectedImages: [UIImage], imagePath: URL?) {
        for selectedImage in selectedImages {
            DispatchQueue.global(qos: .background).async {
                guard let _ = selectedImage.pngData() else { return }

                // 画像のファイルパスを取得
                DispatchQueue.main.async {
                    if let imagePath = imagePath {
                        let imagePathString = imagePath.lastPathComponent
                        
                        store(image: selectedImage, forKey: imagePathString)
                    } else {
                        let fileName = "your_default_filename.png"
                        store(image: selectedImage, forKey: fileName)
                    }
                }
            }
        }
    }



    func store(image: UIImage, forKey key: String) {
        let fileManager = FileManager.default
        guard let filePath = filePath(forKey: key),
              !fileManager.fileExists(atPath: filePath.path) else { return }

        // ファイルが存在しない場合のみ保存
        if let pngRepresentation = image.pngData() {
            do {
                try pngRepresentation.write(to: filePath, options: .atomic)
                print("Image saved at: \(filePath)")
            } catch let err {
                print("Saving file resulted in error: ", err)
            }
        }
    }

     // キーに対応するファイルパスを取得する
     func filePath(forKey key: String) -> URL? {
         let fileManager = FileManager.default
         guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                  in: .userDomainMask).first else { return nil }
         return documentURL.appendingPathComponent(key + ".png")
     }
 }

struct PickImagesView_Previews: PreviewProvider {
    static var previews: some View {
        PickOneView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
