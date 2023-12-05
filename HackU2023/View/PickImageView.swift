//
//  PickImageView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import UIKit


struct PickImageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>
    
    @State private var selectedImage: UIImage?
    @State private var imagePath: URL?
    @State private var isImagePickerDisplayed = false
    @State private var isActive = false
    
    let screen: CGRect = UIScreen.main.bounds

    var body: some View {
        NavigationStack {
            ZStack {
                if let selectedImage = selectedImage {
                    Image("Hacku_select2")
                        .resizable()
                        .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
                } else {
                    Image("Hacku_select")
                        .resizable()
                        .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
                }
                VStack {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                        Button("診断を始める") {
                            isActive = true
                            user.first?.exp += 1
                            saveImage(selectedImage: selectedImage, imagePath: imagePath)
                        }
                        .padding()
                                .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .frame(maxWidth: screen.width / 2)
                                .frame(maxHeight: screen.height / 5)
                        .navigationDestination(isPresented: $isActive) {
                            LabelPredictionView(selectedImage: $selectedImage)
                        }
                        Button("画像を選択") {
                            isImagePickerDisplayed = true
                        }
                        .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .frame(maxWidth: screen.width / 2)
                                .frame(maxHeight: screen.height / 5)
                    } else {
                        Button("画像を選択") {
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
                }
            }
        }
        .sheet(isPresented: $isImagePickerDisplayed) {
            ImagePicker(selectedImage: $selectedImage, imagePath: $imagePath)
        }

    }


    func saveImage(selectedImage: UIImage?, imagePath: URL?) {
        DispatchQueue.global(qos: .background).async {
            guard let selectedImage = selectedImage,
                  let _ = selectedImage.pngData() else { return }
            
            // 画像のファイルパスを取得
            DispatchQueue.main.async {
                if let imagePath = imagePath {
                    let imagePathString = imagePath.lastPathComponent // ファイル名のみ取得
                    
                    store(image: selectedImage, forKey: imagePathString)
                } else {
                    // imagePathがnilの場合、別の方法でファイル名を生成
                    let fileName = "your_default_filename.png" // ここにデフォルトのファイル名を指定
                    store(image: selectedImage, forKey: fileName)
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

struct PickImageView_Previews: PreviewProvider {
    static var previews: some View {
        PickImageView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
