//
//  LabelPredictionView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import Vision
import UIKit

struct LabelPredictionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>
    @State private var predictionResult = "ラベルを推定中..."
    @State private var isActiveRetrain = false
    @State private var isActiveHome = false
    @State private var feedback = ""
    @Binding var selectedImage: UIImage?
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
                            Image(uiImage: selectedImage ?? UIImage(named: "tops.png")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                            Image(uiImage: selectedImage ?? UIImage(named: "tops.png")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
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
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                            .navigationDestination(isPresented: $isActiveRetrain) {
                                RetrainingView(feedback: $feedback, selectedImage: $selectedImage)
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
                                RetrainingView(feedback: $feedback, selectedImage: $selectedImage)
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
            // MLモデルを使用してラベル推定
            let imageToPredict = selectedImage ?? UIImage(named: "tops.png")!
            predictLabel(image: imageToPredict)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                assuming = false
            }
        }
    }
    
    func predictLabel(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNetV2_pytorch().model) else { return }

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
            let handler = VNImageRequestHandler(ciImage: ciImage)

            do {
                try handler.perform([request])
            } catch {
                print("Error performing classification: \(error)")
            }
        }
    }
}

struct LabelPredictionView_Previews: PreviewProvider {
    static var previews: some View {
        LabelPredictionView(selectedImage: .constant(UIImage(named: "tops.png")))
    }
}
