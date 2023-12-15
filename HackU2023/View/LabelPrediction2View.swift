//
//  LabelPredictionView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import Vision
import UIKit

struct LabelPrediction2View: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>
    
    @ObservedObject private var weatherAPI = WeatherAPI()

    @State private var predictionResult = "ラベルを推定中..."
    @State private var isActiveRetrain = false
    @State private var isActiveHome = false
    @State private var feedback = ""
    @State public var combinedImage: UIImage?
    @State private var weather = ""

    @Binding var selectedImages: [UIImage]

    let screen: CGRect = UIScreen.main.bounds
    
    @State private var assuming = true
    @State private var items = ["", "", "", ""]

    var body: some View {
        NavigationStack {
            if assuming {
                ZStack {
                    Image(items[2])
                        .resizable()
                        .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
                        .frame(maxWidth: screen.width / 0.9)
                        .frame(maxHeight: screen.height / 0.9)
                    VStack {
                        Text(printRandomString())
                            .font(.system(size: 28))
                            .bold()
                        Spacer()
                            .frame(height: screen.height / 1.6)
                    }
                    VStack {
                        Spacer()
                            .frame(height: screen.height / 2)
                        HStack {
                            Spacer()
                            Text("考え中...")
                                .font(.system(size: 32))
                                .bold()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                }
            }
            else {
                ZStack {
                    Image("Hacku_select2")
                        .resizable()
                        .frame(maxWidth: screen.width / 0.9)
                        .frame(maxHeight: screen.height / 0.9)
                    VStack {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: resizeImage(image: image, targetSize: CGSize(width: 200, height: 200)))
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Text(predictionResult)
                            .font(.system(size: 32))
                            .bold()
                            .background(Color.white)
                            .foregroundColor(.black)
                        Spacer()
                        // 3画面に遷移
                        HStack {
                            Button("これにする") {
                                feedback = "おしゃれ"
                                isActiveRetrain = true
                            }
                            .padding()
                            .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrain) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage, items: $items, weather: $weather)
                            }
                            // 3画面目に遷移
                            Button("やめとく") {
                                feedback = "おしゃれじゃない"
                                isActiveRetrain = true
                                
                                if combinedImage == nil {
                                    // combinedImage が nil の場合、適切に設定
                                    if selectedImages.count >= 2 {
                                        combinedImage = combineImages(selectedImages[0], selectedImages[1])
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrain) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage, items: $items, weather: $weather)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            items = checkAndUpdateLevel(for: user.first!)
            // MLモデルを使用してラベル推定
            DispatchQueue.main.async {
                if selectedImages.count >= 2, let combinedImage = combineImages(selectedImages[0], selectedImages[1]),
                   let data = weatherAPI.weatherData, let usr = user.first, let gender = usr.gender {

                    let weatherCode = data.weather.first?.main ?? ""
                    
                    // 現在の日付を取得
                    let currentDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: currentDate)
                    // 季節を出力
                    let season = seasonFromDates([dateString])
                    weather = weatherAPI.getWeatherCategory_for_predict(weatherAPI.getWeatherCategory(from: weatherCode).rawValue)

                    if let model = selectModel(gender: gender, season: season, weather: weather) {
                        predictLabel(image: combinedImage, model: model)
                    }
                }
            }



            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                assuming = false
            }
        }
    }
    
    func predictLabel(image: UIImage?, model: VNCoreMLModel) {
        guard let image = image else { return }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                // 「おしゃれ」ラベルの結果を探す
                if let stylishResult = results.first(where: { $0.identifier == "おしゃれ" }) {
                    DispatchQueue.main.async {
                        // 「おしゃれ」ラベルの信頼度を設定
                        self.predictionResult = "おしゃれ度:\(Int(stylishResult.confidence * 100))%"
                    }
                }
            }
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
    
    func combineImages(_ firstImage: UIImage, _ secondImage: UIImage) -> UIImage? {
        let size = CGSize(width: firstImage.size.width, height: firstImage.size.height * 2)
        UIGraphicsBeginImageContext(size)

        firstImage.draw(in: CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height))
        secondImage.draw(in: CGRect(x: 0, y: firstImage.size.height, width: secondImage.size.width, height: secondImage.size.height))

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage
    }

}

//func predictLabel(image: UIImage?, firstModel: VNCoreMLModel, secondModel: VNCoreMLModel) {
//    guard let image = image else { return }
//
//    let firstRequest = VNCoreMLRequest(model: firstModel) { [weak self] request, error in
//        guard let self = self else { return }
//        if let results = request.results as? [VNCoreMLFeatureValueObservation],
//           let firstModelOutput = results.first?.featureValue.multiArrayValue {
//            // firstModelOutput を二番目のモデルに渡す
//            self.useSecondModel(firstModelOutput, secondModel: secondModel)
//        }
//    }
//
//    // 最初のモデルを使用して画像を分析
//    if let ciImage = CIImage(image: image) {
//        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
//        do {
//            try handler.perform([firstRequest])
//        } catch {
//            print("Error performing first model classification: \(error)")
//        }
//    }
//}
//
//func useSecondModel(_ firstModelOutput: MLMultiArray, secondModel: VNCoreMLModel) {
//    // 二番目のモデルを使用して推論
//    let secondRequest = VNCoreMLRequest(model: secondModel) { [weak self] request, error in
//        guard let self = self else { return }
//        if let results = request.results as? [VNClassificationObservation],
//           let stylishResult = results.first(where: { $0.identifier == "おしゃれ" }) {
//            DispatchQueue.main.async {
//                // 「おしゃれ」ラベルの信頼度を設定
//                self.predictionResult = "おしゃれ度:\(Int(stylishResult.confidence * 100))%"
//            }
//        }
//    }
//
//    // 二番目のモデルの推論リクエストを作成
//    let secondHandler = VNImageRequestHandler(mlMultiArray: firstModelOutput, options: [:])
//    do {
//        try secondHandler.perform([secondRequest])
//    } catch {
//        print("Error performing second model classification: \(error)")
//    }
//}

//struct LabelPredictionView2_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelPrediction2View(selectedImages: )
//    }
//}
