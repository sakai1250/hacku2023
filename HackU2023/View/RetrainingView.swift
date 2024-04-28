//
//  RetrainingView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import UIKit
import CoreML
import Vision


struct RetrainingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    
    private var user: FetchedResults<ViViTUser>
    
    @ObservedObject private var weatherAPI = WeatherAPI()
    
    @State var isActive = false

    @Binding var feedback: [Double]
    @Binding var combinedImage: UIImage?
    @Binding var items: [String]
    @Binding var weather: String
    @State private var selectedTab: Tab = .home

    let screen: CGRect = UIScreen.main.bounds
    
    @State private var retraining = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(items[3])
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isActive) {
            MainView(selectedTab: $selectedTab).environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                if let usr = user.first, let gender = usr.gender {
                    // 現在の日付を取得
                    let currentDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: currentDate)
                    // 季節を出力
                    let season = seasonFromDates([dateString])
                    print(weather, season, gender)
                    //  学習
                    if let model = selectModel(gender: gender, season: season, weather: weather) {
                        training(image: combinedImage, model: model)
                        self.isActive = true
                    }
                }
                user.first?.exp += 1
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
//  推論
    func training(image: UIImage?, model: VNCoreMLModel) {
        guard let image = image else { return }
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error during the model execution: \(error)")
                return
            }
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let firstResult = results.first,
                  let multiArray = firstResult.featureValue.multiArrayValue
            else {
                print("Failed to retrieve valid results from the model.")
                return
            }
            
            let fc = FullyConnectedNetwork(inputChannels: 64, outputChannels: 2, user: user.first!)
            let featureArray = self.convertToDoubleArray(from: multiArray)

            // Assuming 'feedback' is correctly defined elsewhere in your code
            fc.train(inputs: featureArray, trueOutputs: feedback, learningRate: 0.01, epochs: 3)
            saveFullConne(weights: fc.weights, biases: fc.biases, fc: user.first!)

        }
        
        // 画像をVisionリクエストに変換
        if let ciImage = CIImage(image: image) {
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Error performing classification: \(error)")
            }
        }

    }
//    重みとバイアスの保存
    func saveFullConne(weights: [[Double]], biases: [Double], fc: ViViTUser) {
        print(weights)
        fc.fullconne_sp_w = weights as NSObject
        fc.fullconne_sp_b = biases as NSObject
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    // MLMultiArrayからDouble型の配列へ変換する関数
    private func convertToDoubleArray(from multiArray: MLMultiArray) -> [Double] {
        guard multiArray.dataType == .float32 else {
            print("データタイプがFloat32ではありません。")
            return []
        }

        return (0..<multiArray.count).compactMap { index in
            Double(multiArray[index].floatValue)
        }
    }
}


//struct RetrainingView_Previews: PreviewProvider {
//    @State static var selectedImage = UIImage(named: "tops.png")
//    static var previews: some View {
//        RetrainingView(feedback: .constant("おしゃれ"), combinedImage: $combinedImage)
//    }
//}
