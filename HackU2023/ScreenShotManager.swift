//
//  ScreenShotManager.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/05.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class ScreenShotManager: ObservableObject {
    @Published var uiImage: UIImage?
    @Published var showActivityView: Bool = false
    @Published var rect: CGRect = .zero
    @Published var url: URL?
    
    func captureScreenShot(windowScene: UIWindowScene?, rect: CGRect) {
        self.url = fileSave(fileName: "shared.png")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            self.uiImage = window.getImage(rect: self.rect)
            
            if let uiImage = self.uiImage {
                saveImageToDocuments(image: uiImage, fileName: "shared.png")
                self.url = fileSave(fileName: "shared.png")
            }
            self.showActivityView.toggle()
        }
        
        func saveImageToDocuments(image: UIImage, fileName: String) {
            guard let imageData = image.pngData() else { return }
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent(fileName)
                
                do {
                    try imageData.write(to: fileURL, options: .atomic)
                    print("画像が保存されました: \(fileURL)")
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        
        func fileSave(fileName: String) -> URL {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let filePath = dir.appendingPathComponent(fileName, isDirectory: false)
            
            // ファイルの存在を確認
            if FileManager.default.fileExists(atPath: filePath.path) {
                print("ファイルが存在します: \(filePath)")
            } else {
                print("ファイルが存在しません: \(filePath)")
            }
            
            return filePath
        }
    }
}
//
//struct RectangleGetter: View {
//    @Binding var rect: CGRect
//
//    var body: some View {
//        GeometryReader { geometry in
//            self.createView(proxy: geometry)
//        }
//    }
//
//    func createView(proxy: GeometryProxy) -> some View {
//        DispatchQueue.main.async {
//            self.rect = proxy.frame(in: .global)
//        }
//        return Rectangle().fill(Color.clear)
//    }
//}


struct RectangleGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            self.createView(proxy: geometry)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        return Rectangle().fill(Color.clear)
    }
}

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {
        
    }
}
