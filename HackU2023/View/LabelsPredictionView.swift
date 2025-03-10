//
//  LabelPredictionView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import Vision
import UIKit

struct LabelsPredictionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>

    @ObservedObject private var weatherAPI = WeatherAPI()
    @State private var weather = ""
    @State private var season = ""

    @State private var predictionResult = 0
    @State private var predictionResults: [Int] = []
    @State private var isActiveRetrain = false
    @State private var isActiveHome = false
    @State private var feedback = ""
    @State private var combinedImage: UIImage?
    @State private var selectedImages: [UIImage] = []

    @Binding var selectedImagesPair: [[UIImage]]

    let screen: CGRect = UIScreen.main.bounds

    @State private var assuming = true
    @State private var waiting = true
    @State private var items = ["", "", "", ""]
    @State private var currentIndex: Int? = nil

    @State private var selectedTab: Tab = .home


    var body: some View {
        NavigationStack {
            if assuming || waiting {
                ZStack {
                    Image(items[2])
                        .resizable()
                        .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
                        .frame(maxWidth: screen.width / 0.9)
                        .frame(maxHeight: screen.height / 0.9)
//                    VStack {
//                        Spacer()
//                            .frame(height: screen.height*9/10)
//                        AdMobBannerView()
//                    }
                    VStack {
                        HStack {
                            Spacer()
                                .frame(width: screen.width / 10)
                            Text(printRandomString())
                                .font(.system(size: 32))
                                .bold()
                            Spacer()
                                .frame(width: screen.width / 10)

                        }
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
//                .frame(maxWidth: screen.width * 0.9)
                .frame(maxHeight: screen.height * 0.9)
                AdMobBannerView()
                    .frame(width: screen.width * 0.9, height: 50)            }
            else {
                ZStack {
                    Image("Hacku_select2")
                        .resizable()
                        .frame(maxWidth: screen.width / 0.9)
                        .frame(maxHeight: screen.height / 0.9)
//                    VStack {
//                        Spacer()
//                            .frame(height: screen.height*9/10)
//                        AdMobBannerView()
//                    }
                    VStack {
                        ScrollView {
                            ForEach(Array(selectedImagesPair.enumerated()), id: \.offset) { index, _selectedImages in
                                VStack {
                                    HStack {
                                        ForEach(_selectedImages, id: \.self) { image in
                                            Image(uiImage: resizeImage(image: image, targetSize: CGSize(width: 200, height: 200)))
                                                .resizable()
                                                .scaledToFit()
                                        }
                                    }
                                    // 対応する予測結果を表示
                                    if index < predictionResults.count {
                                        Text("おしゃれ度: \(predictionResults[index])%")
                                            .font(.system(size: 32))
                                            .bold()
                                            .background(Color.white)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            Spacer()
                            Button("ホームへ") {
                                isActiveHome = true
                            }
                            .padding()
                            .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            Spacer()
                        }
                    }

                }
//                .frame(maxWidth: screen.width * 0.9)
                .frame(maxHeight: screen.height * 0.9)
                VStack {
                    AdMobBannerView()
                        .frame(width: screen.width * 0.9, height: 50)                }

            }
        }
        .navigationDestination(isPresented: $isActiveHome) {
            MainView().environment(\.managedObjectContext, viewContext)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            items = checkAndUpdateLevel(for: user.first!)
            // MLモデルを使用してラベル推定
            DispatchQueue.main.async {
                if let data = weatherAPI.weatherData {
                    for _selectedImages in selectedImagesPair {
                        if _selectedImages.count >= 2, let combinedImage = combineImages(_selectedImages[0], _selectedImages[1]),
                           let usr = user.first, let gender = usr.gender {
                            let weatherCode = data.weather.first?.main ?? ""
                            
                            // 現在の日付を取得
                            let currentDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let dateString = dateFormatter.string(from: currentDate)
                            // 季節を出力
                            let season = seasonFromDates([dateString])
                            let weather = weatherAPI.getWeatherCategory_for_predict(weatherAPI.getWeatherCategory(from: weatherCode).rawValue)

//                            print(gender, season, weather)
                            if let model = try? VNCoreMLModel(for: Enocoder().model) {
//                            if let model = selectModel(gender: gender, season: season, weather: weather) {
                                let fc = FullyConnectedNetwork(inputChannels: 64, outputChannels: 2, user: user.first!, gender: gender, season: season, weather: weather)
                                predictLabel(image: combinedImage, model: model, fc: fc)
                            }
                        }
                        
                        else {
                        }
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                waiting = false
            }
        }
    }
    //  推論
    func predictLabel(image: UIImage?, model: VNCoreMLModel, fc: FullyConnectedNetwork) {
        guard let image = image else { return }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let firstResult = results.first,
                  let multiArray = firstResult.featureValue.multiArrayValue else { return }
            //  分類器
            let featureArray = self.convertToDoubleArray(from: multiArray)

            var fcResults = fc.infer(input: featureArray)
            let stylishResult  = softmax(fcResults)[0]
            
            DispatchQueue.main.async {
                // 「おしゃれ」ラベルの信頼度を設定
                self.predictionResult = Int((stylishResult) * 100)
                self.predictionResults.append(self.predictionResult)
            
                if let highestValue = self.predictionResults.max() {
                    if let index = self.predictionResults.firstIndex(of: highestValue) {
                        print("最も高い値: \(highestValue), 位置番号: \(index)")
                        self.predictionResult = self.predictionResults[index]
                        self.selectedImages = selectedImagesPair[index]
                        print("結果\(self.predictionResults)")
                    }
                } else {
                    print("配列が空です")
                }
                self.assuming = false
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
    
    func softmax(_ x: [Double]) -> [Double] {
        let exps = x.map { exp($0) }
        let sumExps = exps.reduce(0, +)
        return exps.map { $0 / sumExps }
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

//struct LabelsPredictionView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelsPredictionView(selectedImages: )
//    }
//}
