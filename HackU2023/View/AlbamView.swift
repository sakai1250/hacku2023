//
//  ContentView.swift
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import CryptoKit
import CoreData
import Foundation
import UIKit
import Photos

struct AlbamView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isImagePickerDisplayed = false
    @State private var isImageSaved = false

    @State private var selectedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    
    @State private var imageCombinations: [[URL]] = []
    
    @State private var topsImageURLs: [URL] = []
    @State private var bottomsImageURLs: [URL] = []
    
    let screen: CGRect = UIScreen.main.bounds
    
    @State private var selectedTab: Tab = .editphoto

    var body: some View {
        NavigationView {
            ZStack {
                Image("Hacku_select2")
                    .resizable()
                    .frame(maxWidth: screen.width / 0.9)
                    .frame(maxHeight: screen.height / 0.9)
                VStack {
//                    ScrollView {
                        if !selectedImages.isEmpty {
                            ScrollView {
                                HStack {
                                    ForEach(selectedImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                        
                                    }
                                    .padding()
                                    .background(Color.brown)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        Group {
                            Text("上の服")
                                .font(.system(size: 28))
                                .bold()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .padding()
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(topsImageURLs, id: \.self) { imageUrl in
                                            let originalImage = UIImage(contentsOfFile: imageUrl.path) ?? UIImage()
                                            let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 100, height: 100))

                                            Image(uiImage: resizedImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 100)
                                                .onTapGesture {
                                                    deleteImage(at: imageUrl)
                                                }
                                        }

                                    }
                                }
                            if topsImageURLs.isEmpty && selectedImages.isEmpty {
                                    Text("画像が存在しません")
                                        .font(.system(size: 20))
                                        .bold()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .padding()
                            }
                        }
                        
                        Group {
                            Text("下の服")
                                .font(.system(size: 28))
                                .bold()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .padding()
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(bottomsImageURLs, id: \.self) { imageUrl in
                                            let originalImage = UIImage(contentsOfFile: imageUrl.path) ?? UIImage()
                                            let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 128, height: 128))

                                            Image(uiImage: resizedImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 128, height: 128)
                                                .onTapGesture {
                                                    deleteImage(at: imageUrl)
                                                }
                                        }

                                    }
                                }
                            if topsImageURLs.isEmpty && bottomsImageURLs.isEmpty && selectedImages.isEmpty {
                                    Text("画像が存在しません")
                                        .font(.system(size: 20))
                                        .bold()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .padding()
                            }
                        }
                        HStack {
                            Button("服を選ぶ") {
                                checkPhotoLibraryAuthorization()
                            }
                            .padding()
                            .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            if !selectedImages.isEmpty {
                                Button("上の服として保存") {
                                    saveImage(selectedImages, to: "tops")
                                    self.isImageSaved = true
                                }
                                .padding()
                                .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .frame(maxWidth: screen.width / 2)
                                .frame(maxHeight: screen.height / 5)
                                
                                Button("下の服として保存") {
                                    saveImage(selectedImages, to: "bottoms")
                                    self.isImageSaved = true
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
                        .sheet(isPresented: $isImagePickerDisplayed) {
                            ImagePicker(selectedImages: $selectedImages)
                    }
                    .onAppear {
                        createFolders()
                        imageCombinations = generateCombinations()
                        topsImageURLs = fetchImageURLs(from: "tops")
                        bottomsImageURLs = fetchImageURLs(from: "bottoms")
                    }
                    .navigationDestination(isPresented: $isImageSaved) {
                        MainView().environment(\.managedObjectContext, viewContext)
                    }

                }
            }
        }
        
    }

    func saveImage(_ images: [UIImage], to folder: String) {
            for image in images {
                guard let imageData = image.jpegData(compressionQuality: 1),
                      let hash = generateHash(for: imageData) else {
                    print("Error in image processing")
                    continue
                }

                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let folderURL = documentDirectory.appendingPathComponent(folder)
                let fileURL = folderURL.appendingPathComponent("\(hash).jpg")

                if checkForDuplicateImage(hash: hash, context: viewContext) {
                    print("Duplicate image")
                    continue
                }

                do {
                    try imageData.write(to: fileURL)
                    saveImageHashToCoreData(hash: hash)
                } catch {
                    print("Error saving image: \(error)")
                }
            }

            imageCombinations = generateCombinations() // リストを更新
        }

    func saveImageHashToCoreData(hash: String) {
        let newImage = ImageEntity(context: viewContext)
        newImage.imageHash = hash

        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func deleteImage(at url: URL) {
        let fileManager = FileManager.default

        // 画像のハッシュ値を取得（画像データからハッシュを再計算）
        guard let imageData = try? Data(contentsOf: url),
              let hash = generateHash(for: imageData) else {
            print("Error calculating hash for image")
            return
        }

        // Core Dataからハッシュ値を持つエンティティを削除
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageEntity")
        fetchRequest.predicate = NSPredicate(format: "imageHash == %@", hash)

        do {
            let results = try viewContext.fetch(fetchRequest) as? [ImageEntity]
            results?.forEach { entity in
                viewContext.delete(entity)
            }
            try viewContext.save()
        } catch {
            print("Error deleting entity: \(error)")
            return
        }

        // 画像をファイルシステムから削除
        do {
            try fileManager.removeItem(at: url)
            // topsImageURLs と bottomsImageURLs を更新
            topsImageURLs = fetchImageURLs(from: "tops")
            bottomsImageURLs = fetchImageURLs(from: "bottoms")
        } catch {
            print("Error deleting image: \(error)")
        }
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

func generateHash(for imageData: Data) -> String? {
    let hash = SHA256.hash(data: imageData)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}


func checkForDuplicateImage(hash: String, context: NSManagedObjectContext) -> Bool {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageEntity")
    fetchRequest.predicate = NSPredicate(format: "imageHash == %@", hash)

    do {
        let results = try context.fetch(fetchRequest)
        return results.count > 0
    } catch {
        print("Error fetching data: \(error)")
        return false
    }
}



func createFolders() {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

    let topsPath = documentDirectory.appendingPathComponent("tops")
    let bottomsPath = documentDirectory.appendingPathComponent("bottoms")

    do {
        try createFolderIfNeeded(at: topsPath, using: fileManager)
        try createFolderIfNeeded(at: bottomsPath, using: fileManager)
    } catch {
        print("Error creating folders: \(error)")
    }
}

func createFolderIfNeeded(at path: URL, using fileManager: FileManager) throws {
    if !fileManager.fileExists(atPath: path.path) {
        try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
    }
}

func generateCombinations() -> [[URL]] {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }

    let topsPath = documentDirectory.appendingPathComponent("tops")
    let bottomsPath = documentDirectory.appendingPathComponent("bottoms")

    let topsFiles = (try? fileManager.contentsOfDirectory(atPath: topsPath.path))?.filter { $0 != ".DS_Store" } ?? []
    let bottomsFiles = (try? fileManager.contentsOfDirectory(atPath: bottomsPath.path))?.filter { $0 != ".DS_Store" } ?? []

    var combinations = [[URL]]()

    for top in topsFiles {
        for bottom in bottomsFiles {
            let topURL = topsPath.appendingPathComponent(top)
            let bottomURL = bottomsPath.appendingPathComponent(bottom)
            combinations.append([topURL, bottomURL])
        }
    }

    return combinations
}

func checkExistUrl() -> [URL] {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }

    let topsPath = documentDirectory.appendingPathComponent("tops")
    let bottomsPath = documentDirectory.appendingPathComponent("bottoms")

    let topsFiles = (try? fileManager.contentsOfDirectory(atPath: topsPath.path))?.filter { $0 != ".DS_Store" } ?? []
    let bottomsFiles = (try? fileManager.contentsOfDirectory(atPath: bottomsPath.path))?.filter { $0 != ".DS_Store" } ?? []

    var urlsForCheck = [URL]()

    for top in topsFiles {
        let topURL = topsPath.appendingPathComponent(top)
        urlsForCheck.append(topURL)
    }
    for bottom in bottomsFiles {
        let bottomURL = bottomsPath.appendingPathComponent(bottom)
        urlsForCheck.append(bottomURL)
    }

    return urlsForCheck
}

func generateCombinations_customed(images1: [UIImage], images2: [UIImage]) -> [[UIImage]] {
    var combinations = [[UIImage]]()

    for image1 in images1 {
        for image2 in images2 {
            combinations.append([image1, image2])
        }
    }

    return combinations
}



func fetchImageURLs(from folder: String) -> [URL] {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
    let folderURL = documentDirectory.appendingPathComponent(folder)

    let fileURLs = (try? fileManager.contentsOfDirectory(atPath: folderURL.path)) ?? []
    return fileURLs.map { folderURL.appendingPathComponent($0) }
}


func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }

    let rect = CGRect(origin: .zero, size: newSize)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage ?? image
}
