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
    @State private var predictionResult = "ラベルを推定中..."
    @State private var isActiveRetrain = false
    @State private var isActiveHome = false
    @State private var feedback = ""
    @Binding var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack {
                Image(uiImage: selectedImage ?? UIImage(named: "tops.png")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text(predictionResult)
                
                // 3画面に遷移
                Button("合ってる") {
                    feedback = "おしゃれ"
                    isActiveRetrain = true
                }
                .navigationDestination(isPresented: $isActiveRetrain) {
                    RetrainingView(feedback: $feedback, selectedImage: $selectedImage)
                }
                // 3画面目に遷移
                Button("間違い") {
                    feedback = "おしゃれじゃない"
                    isActiveRetrain = true
                }
                .navigationDestination(isPresented: $isActiveRetrain) {
                    RetrainingView(feedback: $feedback, selectedImage: $selectedImage)
                }
            }
        }.onAppear {
            // MLモデルを使用してラベル推定
            let imageToPredict = selectedImage ?? UIImage(named: "tops.png")!
            predictLabel(image: imageToPredict)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isActiveHome = true
                })
                    {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("HONE")
                    }
                    .navigationDestination(isPresented: $isActiveHome) {
                        MainView()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func predictLabel(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNetV2_pytorch().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
               if let topResult = results.first {
                   DispatchQueue.main.async {
                    self.predictionResult = "\(topResult.identifier) (\(topResult.confidence * 100)%)"
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
