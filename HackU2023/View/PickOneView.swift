//
//  PickImageView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import UIKit
import Photos


struct PickOneView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>
    enum AlertType {
        case none
        case tops
        case bottoms
    }

    @State private var alertType: AlertType = .none

    @State private var selectedImages: [UIImage] = []
    @State private var selectedImagesPair: [[UIImage]] = [[]]
    @State private var imagePath: URL?
    @State private var isImagePickerDisplayed = false
    @State private var isActiveTop = false
    @State private var isActiveBottom = false
    @State private var isActiveHome = false
    @State private var isActiveBack = false
    @State private var isEmpty = true
    @State private var selectedTab: Tab = .home

    @State private var topsImages: [UIImage] = []
    @State private var bottomsImages: [UIImage] = []

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
                        if !selectedImages.isEmpty {
                                VStack {
                                    HStack {
                                        ForEach(selectedImages, id: \.self) { image in
                                            Image(uiImage: resizeImage(image: image, targetSize: CGSize(width: 200, height: 200)))
                                                .resizable()
                                                .scaledToFit()
                                        }
                                    }

                                    Button("服を選ぶ") {
                                        checkPhotoLibraryAuthorization()
                                    }
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .frame(maxWidth: screen.width / 2)
                                        .frame(maxHeight: screen.height / 5)
                                }
                                HStack {
                                    Button("上の服と診断") {
                                        if topsImages.isEmpty {
                                            alertType = .tops
                                        } else {
                                            isActiveTop = true
                                            selectedImagesPair = generateCombinations_customed(images1: topsImages, images2: selectedImages)
                                        }
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .frame(maxWidth: screen.width / 2)
                                    .frame(maxHeight: screen.height / 5)
                                    .navigationDestination(isPresented: $isActiveTop) {
                                        LabelsPredictionView(selectedImagesPair: $selectedImagesPair)
                                    }
                                    Button("下の服と診断") {
                                        if bottomsImages.isEmpty {
                                            alertType = .bottoms
                                        } else {
                                            isActiveBottom = true
                                            selectedImagesPair = generateCombinations_customed(images1: selectedImages, images2: bottomsImages)

                                        }

                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .frame(maxWidth: screen.width / 2)
                                    .frame(maxHeight: screen.height / 5)
                                    .navigationDestination(isPresented: $isActiveBottom) {
                                        LabelsPredictionView(selectedImagesPair: $selectedImagesPair)
                                    }
                                }
                            }
                            else {
                            Button("服を選ぶ") {
                                checkPhotoLibraryAuthorization()
                            }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.black)
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
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .frame(maxWidth: screen.width / 2)
                        .frame(maxHeight: screen.height / 5)
                    }
                }

            }
            .navigationDestination(isPresented: $isActiveBack) {
                MainView().environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $isImagePickerDisplayed) {
                ImagePicker(selectedImages: $selectedImages)
            }
            .alert(isPresented: Binding<Bool>(
                get: { alertType != .none },
                set: { _ in alertType = .none }
            )) {
                switch alertType {
                case .tops:
                    return Alert(
                        title: Text("エラー"),
                        message: Text("上の服の画像がありません。下の「アルバム」から上の服を選択・保存することで、その中からベストな組み合わせを選択します。"),
                        dismissButton: .default(Text("OK"))
                    )
                case .bottoms:
                    return Alert(
                        title: Text("エラー"),
                        message: Text("下の服の画像がありません。下の「アルバム」から下の服を選択・保存することで、その中からベストな組み合わせを選択します。"),
                        dismissButton: .default(Text("OK"))
                    )
                case .none:
                    return Alert(title: Text("")) // 何も表示しない
                }
            }
            .onAppear {
                topsImages = convertURLsToUIImages(urls: fetchImageURLs(from: "tops"))
                bottomsImages = convertURLsToUIImages(urls: fetchImageURLs(from: "bottoms"))
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func convertURLsToUIImages(urls: [URL]) -> [UIImage] {
        return urls.compactMap { url in
            UIImage(contentsOfFile: url.path) // 各URLからUIImageを生成
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
    
    func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.isImagePickerDisplayed = true
                    }
                }
            }
        } else if status == .authorized {
            self.isImagePickerDisplayed = true
        } else {
            // アクセスが拒否された場合の処理
            // 例: 設定を開くためのアラートを表示する
        }
    }
 }


