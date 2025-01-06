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
//                VStack {
//                    Spacer()
//                        .frame(height: screen.height*9/10)
//                    AdMobBannerView()
//                }
                
            }
//            .frame(maxWidth: screen.width * 0.9)
            .frame(maxHeight: screen.height * 0.9)
            AdMobBannerView()
                .frame(width: screen.width * 0.9, height: 50)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isActive) {
            MainView().environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            print("Retrain view start")
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
                    print("start retraining")
                    if let model = try? VNCoreMLModel(for: Enocoder().model) {
//                    if let model = selectModel(gender: gender, season: season, weather: weather) {
                        let fc = FullyConnectedNetwork(inputChannels: 64, outputChannels: 2, user: user.first!, gender: gender, season: season, weather: weather)
                        training(image: combinedImage, model: model, fc: fc, gender: gender, season: season, weather: weather)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isActive = true
            }
        }
    }
//  推論
    func training(image: UIImage?, model: VNCoreMLModel, fc: FullyConnectedNetwork, gender: String, season: String, weather: String) {
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
            
            let featureArray = self.convertToDoubleArray(from: multiArray)

            // Assuming 'feedback' is correctly defined elsewhere in your code
            print("Retraining...")
            fc.train(inputs: featureArray, trueOutputs: feedback, learningRate: 0.01, epochs: 3)
            print("saveFullConne")
            saveFullConne(weights: fc.weights, biases: fc.biases, fc: user.first!, gender: gender, season: season, weather: weather)
            print("done saveFullConne")
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
    func saveFullConne(weights: [[Double]], biases: [Double], fc: ViViTUser, gender: String, season: String, weather: String) {
        print(weights)
        switch (gender, season, weather) {
        case ("男性", "春", "晴れ"):
            fc.fullconne_w_spms = weights as NSObject
            fc.fullconne_b_spms = biases as NSObject
        case ("男性", "春", "雨"):
            fc.fullconne_w_smmr = weights as NSObject
            fc.fullconne_b_spmr = biases as NSObject
        case ("男性", "夏", "晴れ"):
            fc.fullconne_w_smms = weights as NSObject
            fc.fullconne_b_smms = biases as NSObject
        case ("男性", "夏", "雨"):
            fc.fullconne_w_smmr = weights as NSObject
            fc.fullconne_b_smmr = biases as NSObject
        case ("男性", "秋", "晴れ"):
            fc.fullconne_w_fms = weights as NSObject
            fc.fullconne_b_fms = biases as NSObject
        case ("男性", "秋", "雨"):
            fc.fullconne_w_fmr = weights as NSObject
            fc.fullconne_b_fmr = biases as NSObject
        case ("男性", "冬", "晴れ"):
            fc.fullconne_w_wms = weights as NSObject
            fc.fullconne_b_wms = biases as NSObject
        case ("男性", "冬", "雨"):
            fc.fullconne_w_wmr = weights as NSObject
            fc.fullconne_b_wmr = biases as NSObject
        
        case ("女性", "春", "晴れ"):
            fc.fullconne_w_spws = weights as NSObject
            fc.fullconne_b_spws = biases as NSObject
        case ("女性", "春", "雨"):
            fc.fullconne_w_spwr = weights as NSObject
            fc.fullconne_b_spwr = biases as NSObject
        case ("女性", "夏", "晴れ"):
            fc.fullconne_w_smws = weights as NSObject
            fc.fullconne_b_smws = biases as NSObject
        case ("女性", "夏", "雨"):
            fc.fullconne_w_smwr = weights as NSObject
            fc.fullconne_b_smwr = biases as NSObject
        case ("女性", "秋", "晴れ"):
            fc.fullconne_w_fws = weights as NSObject
            fc.fullconne_b_fws = biases as NSObject
        case ("女性", "秋", "雨"):
            fc.fullconne_w_fwr = weights as NSObject
            fc.fullconne_b_fwr = biases as NSObject
        case ("女性", "冬", "晴れ"):
            fc.fullconne_w_wws = weights as NSObject
            fc.fullconne_b_wws = biases as NSObject
        case ("女性", "冬", "雨"):
            fc.fullconne_w_wwr = weights as NSObject
            fc.fullconne_b_wwr = biases as NSObject

        default:
            fc.fullconne_w_spms = weights as NSObject
            fc.fullconne_b_spms = biases as NSObject
        }
        
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
