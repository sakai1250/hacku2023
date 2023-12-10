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
    @State private var isActiveRetrain = false
    @State private var isActiveHome = false
    @State private var feedback = ""
    @State private var combinedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var weather = ""

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
                        Text("おしゃれ度:\(predictionResult)%")
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
//                            Button("やめとく") {
//                                if currentIndex == nil {
//                                    currentIndex = selectedImagesPair.firstIndex(where: { $0 == selectedImages })
//                                }
//                                if let currentIndex = currentIndex, currentIndex < selectedImagesPair.count {
//                                    // 次の組み合わせを表示
//                                    selectedImages = selectedImagesPair[self.currentIndex!]
//                                    predictionResult = predictionResults[self.currentIndex!]
//                                    combinedImage = combineImages(selectedImagesPair[self.currentIndex!][0], selectedImagesPair[self.currentIndex!][1])
//                                    self.currentIndex! += 1
//                                } else {
//                                    // 配列の最後に達した場合、RetrainingViewに遷移
//                                    feedback = "おしゃれじゃない"
//                                    isActiveRetrain = true
//                                    currentIndex = nil // currentIndexをリセット
//                                }
//                            }
                            
                            Button("やめとく") {
                                if isfirst {
                                    sortedIndices.removeFirst()
                                    isfirst = false
                                }
                                // 次の画像を表示
                                if let currentIndex = sortedIndices.first {
                                    print(currentIndex)
                                    selectedImages = selectedImagesPair[currentIndex]
                                    predictionResult = predictionResults[currentIndex]
                                    combinedImage = combineImages(selectedImagesPair[currentIndex][0], selectedImagesPair[currentIndex][1])
                                    sortedIndices.removeFirst()
                                } else {
                                    // 画像がもうない場合、RetrainingViewに遷移
                                    feedback = "おしゃれじゃない"
                                    isActiveRetrain = true
                                }
                            }
                            
                            .navigationDestination(isPresented: $isActiveRetrain) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage, items: $items, weather: $weather)
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
            
            DispatchQueue.main.async {
                // MLモデルを使用してラベル推定
                if let data = weatherAPI.weatherData {
                    for _selectedImages in selectedImagesPair {
                        if _selectedImages.count >= 2, let combinedImage = combineImages(_selectedImages[0], _selectedImages[1]),
                           let usr = user.first, let gender = usr.gender {
                            
                            let weatherCode = data.weather.first?.description ?? ""
                            let weather = weatherAPI.getWeatherCategory_for_predict(weatherAPI.getWeatherCategory(from: weatherCode).rawValue)

                            // 現在の日付を取得
                            let currentDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let dateString = dateFormatter.string(from: currentDate)
                            // 季節を出力
                            let season = seasonFromDates([dateString])
                            print(gender, season, weather)
                            if let model = selectModel(gender: gender, season: season, weather: weather) {
                                predictLabel(image: combinedImage, model: model)
                            }
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

    func predictLabel(image: UIImage?, model: VNCoreMLModel) {
        guard let image = image else { return }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                // 「おしゃれ」ラベルの結果を探す
                if let stylishResult = results.first(where: { $0.identifier == "おしゃれ" }) {
                    DispatchQueue.main.async {
                        // 「おしゃれ」ラベルの信頼度を設定
                        self.predictionResult = Int(stylishResult.confidence * 100)
                        self.predictionResults.append(self.predictionResult)
                    
                        if let highestValue = self.predictionResults.max() {
                            if let index = self.predictionResults.firstIndex(of: highestValue) {
                                print("最も高い値: \(highestValue), 位置番号: \(index)")
                                self.predictionResult = self.predictionResults[index]
                                self.selectedImages = selectedImagesPair[index+1]
                                print("結果\(self.predictionResults)")
                                // 予測結果とインデックスを関連付けてソート
                                let sortedResults = predictionResults
                                    .enumerated()
                                    .sorted { $0.element > $1.element }
                                    .map { $0.offset }
                                sortedIndices = sortedResults
                            }
                        } else {
                            print("配列が空です")
                        }
                        self.assuming = false
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
