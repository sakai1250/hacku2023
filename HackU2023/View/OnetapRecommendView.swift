//
//  OnetapRecommendView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/09.
//

import SwiftUI
import Vision
import UIKit

struct OnetapRecommendView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>

    @ObservedObject private var weatherAPI = WeatherAPI()

    @State private var predictionResult = 0
    @State private var predictionResults: [Int] = []
    @State private var isActiveRetrainOK = false
    @State private var isActiveRetrainNG = false
    @State private var isActiveHome = false
    @State private var feedback: [Double] = [0.0, 0.0]
    @State private var combinedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var weather = ""
    @State private var season = ""

    @Binding var selectedImagesPair: [[UIImage]]

    let screen: CGRect = UIScreen.main.bounds

    @State private var assuming = true
    @State private var waiting = true
    @State private var items = ["", "", "", ""]
    @State private var currentIndex: Int? = nil
    @State private var sortedIndices: [Int] = []
    @State private var isfirst = true


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
                VStack {
                    AdMobBannerView()
                        .frame(width: screen.width * 0.9, height: 50)                }
            }
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
//
//                    }
                    VStack {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: resizeImage(image: image, targetSize: CGSize(width: 200, height: 200)))
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Text("おしゃれ度:\(predictionResult)%")
                            .font(.system(size: 32))
                            .bold()
                            .background(Color.white)
                            .foregroundColor(.black)
                        Spacer()
                        // 3画面に遷移
                        HStack {
                            Button("これにする") {
                                feedback = [1.0, 0.0] as [Double]
                                isActiveRetrainOK = true
                                print("これにする: \(isActiveRetrainOK)") // デバッグログ

                            }
                            .padding()
                            .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrainOK) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage, items: $items, weather: $weather)
                            }
                            
                            Button("やめとく") {
                                // 次の画像を表示
                                if let currentIndex = sortedIndices.first {
                                    print(currentIndex)
                                    selectedImages = selectedImagesPair[currentIndex]
                                    predictionResult = predictionResults[currentIndex]
                                    combinedImage = combineImages(selectedImagesPair[currentIndex][0], selectedImagesPair[currentIndex][1])
                                    sortedIndices.removeFirst()
                                } else {
                                    // 画像がもうない場合、RetrainingViewに遷移
                                    feedback = [0.0, 1.0] as [Double]
                                    isActiveRetrainNG = true
                                }
                                print("やめとく: \(isActiveRetrainNG)") // デバッグログ
                            }
                            
//                            .navigationDestination(isPresented: $isActiveRetrain) {
//                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage, items: $items, weather: $weather)
//                            }

                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrainNG) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage, items: $items, weather: $weather)
                            }


                        }
                        Spacer()
                    }
                }
//                .frame(maxWidth: screen.width * 0.9)
                .frame(maxHeight: screen.height * 0.9)
                VStack {
                    AdMobBannerView()
                        .frame(width: screen.width * 0.9, height: 50)                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            items = checkAndUpdateLevel(for: user.first!)
            
            DispatchQueue.main.async {
                // MLモデルを使用してラベル推定
                if let data = weatherAPI.weatherData {
                    for _selectedImages in selectedImagesPair {
                        if _selectedImages.count >= 2, let combinedImage = combineImages(_selectedImages[0], _selectedImages[1]),
                           let usr = user.first, let gender = usr.gender {
                            
                            let weatherCode = data.weather.first?.main ?? ""
                            let weather = weatherAPI.getWeatherCategory_for_predict(weatherAPI.getWeatherCategory(from: weatherCode).rawValue)

                            // 現在の日付を取得
                            let currentDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let dateString = dateFormatter.string(from: currentDate)
                            // 季節を出力
                            let season = seasonFromDates([dateString])
                            print(gender, season, weather)
                            if let model = try? VNCoreMLModel(for: Enocoder().model) {
//                            if let model = selectModel(gender: gender, season: season, weather: weather) {
                                let fc = FullyConnectedNetwork(inputChannels: 64, outputChannels: 2, user: user.first!, gender: gender, season: season, weather: weather)
                                predictLabel(image: combinedImage, model: model, fc: fc)                            }
                        }
                        
                        
                        else {
                            print("ない")
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

            let fcResults = fc.infer(input: featureArray)
            let stylishResult  = softmax(fcResults)[0]
            
            DispatchQueue.main.async {
                // 「おしゃれ」ラベルの信頼度を設定
                self.predictionResult = Int((stylishResult) * 100)
                self.predictionResults.append(self.predictionResult)
                
                if let highestValue = self.predictionResults.max() {
                    if let index = self.predictionResults.firstIndex(of: highestValue) {
                        print("最も高い値: \(highestValue), 位置番号: \(index)")
                        self.predictionResult = self.predictionResults[index]
                        // 配列の長さを超えているかチェック
                        if index + 1 < selectedImagesPair.count {
                            self.selectedImages = selectedImagesPair[index+1]
                        } else {
                            // 最後の要素の場合、最初に戻るか、別の適切な処理を行う
                            self.selectedImages = selectedImagesPair[0] // 例: 最初の要素に戻る
                        }
                        print("結果\(self.predictionResults[index])")
                    }
                    // 値とインデックスをペアにしてソート
                    let indexedNumbers = self.predictionResults.enumerated().sorted { $0.element > $1.element }
                    print("結果2\(indexedNumbers)")

                    // ソートされたインデックスのみを抽出
                    self.sortedIndices = indexedNumbers.map { $0.offset }
                    print("結果3\(self.predictionResults[0])")

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
