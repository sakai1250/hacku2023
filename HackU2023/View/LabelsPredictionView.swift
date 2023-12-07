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
                                Image(uiImage: image)
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
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrain) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage)
                            }
                            // 3画面目に遷移
                            Button("やめとく") {
                                feedback = "おしゃれじゃない"
                                isActiveRetrain = true
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrain) {
                                RetrainingView(feedback: $feedback, combinedImage: $combinedImage)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    isActiveHome = true
//                    user.first?.exp += 1
//                })
//                {
//                    HStack {
//                        Image(systemName: "arrow.left")
//                        Text("HONE")
//                    }
//                    .navigationDestination(isPresented: $isActiveHome) {
//                        MainView()
//                    }
//                }
//            }
//        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            user.first?.exp += 1
            items = checkAndUpdateLevel(for: user.first!)

//            // MLモデルを使用してラベル推定
//            if selectedImages.count >= 2 {
//                combinedImage = combineImages(selectedImages[0], selectedImages[1])
//                if let data = weatherAPI.weatherData {
//                    if let weatherCode = data.daily.weather_code.first {
//                        if let combinedImage = combinedImage {
//                            if let usr = user.first {
//                                if let gender = usr.gender {
//                                    let season = weatherAPI.seasonFromDates(data.daily.time)
//                                    let weather = weatherAPI.getWeatherCategory_for_predict(weatherAPI.getWeatherCategory(weatherCode).rawValue)
//                                    if let model = selectModel(gender: gender, season: season, weather: weather) {
//                                        predictLabel(image: combinedImage, model: model)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            // MLモデルを使用してラベル推定
            for _selectedImages in selectedImagesPair.dropFirst() {
                if _selectedImages.count >= 2, let combinedImage = combineImages(_selectedImages[0], _selectedImages[1]),
                   let data = weatherAPI.weatherData, let weatherCode = data.daily.weather_code.first,
                   let usr = user.first, let gender = usr.gender {
                    print("画像\(combinedImage)")

                    let season = weatherAPI.seasonFromDates(data.daily.time)
                    let weather = weatherAPI.getWeatherCategory_for_predict(weatherAPI.getWeatherCategory(weatherCode).rawValue)
                    if let model = selectModel(gender: gender, season: season, weather: weather) {
                        predictLabel(image: combinedImage, model: model)
                    }
                }
                else {
                    print("ない")
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

//struct LabelsPredictionView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelsPredictionView(selectedImages: )
//    }
//}
