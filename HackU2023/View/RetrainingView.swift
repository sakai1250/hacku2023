//
//  RetrainingView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import UIKit
import CoreML

struct RetrainingView: View {
    @State var isTrainingComplete = false
    @State var isActive = false
    @State var isTrainingInProgress = false
    @Binding var feedback: String
    @Binding var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack {
                if isTrainingInProgress {
                    Text("再学習中...")
                    ProgressView() // プログレスインジケータを表示
                } else {
                    Text("再学習完了")
                    Button("次へ") {
                        isActive = true
                    }
                }
            }
            .navigationDestination(isPresented: $isActive) {
                RetrainingCompleteView()
            }
        }
            .onAppear {
                startRetraining()
            }
        }
        
    func startRetraining() {
        isTrainingInProgress = true
        let newTrainingData: [TrainingData] = [
            TrainingData(image: self.selectedImage!, label: self.feedback)
        ]
        let newFeatureProviders = newTrainingData.compactMap { createMLFeatureProvider(from: $0) }
        let newData = MLArrayBatchProvider(array: newFeatureProviders)
        retrainModel(with: newData)
    }
    
    func retrainModel(with newData: MLBatchProvider) {
        let modelConfiguration = MLModelConfiguration()
        modelConfiguration.computeUnits = .all // CPUとGPUの両方を使用
        modelConfiguration.allowLowPrecisionAccumulationOnGPU = true

        // 生成されたモデルクラスからモデルのURLを取得
        guard let modelURL = Bundle.main.url(forResource: "MobileNetV2_pytorch", withExtension: "mlmodelc")
        else {
            print("モデルファイルが見つかりません。")
            return
        }
        print("取得成功")
        let updateTask = try? MLUpdateTask(forModelAt: modelURL,
                                           trainingData: newData,
                                           configuration: modelConfiguration,
                                           completionHandler: { context in
            DispatchQueue.main.async {
                if let error = context.task.error {
                    // エラーが発生した場合の処理
                    print("モデル更新エラー: \(error.localizedDescription)")
                    // 必要に応じてユーザーに通知するなどの処理をここに追加
                    self.isTrainingInProgress = false
                    return
                }
                if context.task.state == .completed {
                    self.handleModelUpdate(context)
                    self.isTrainingComplete = true
                }
                self.isTrainingInProgress = false
            }
        })
        updateTask?.resume()
    }


    func handleModelUpdate(_ context: MLUpdateContext) {
        do {
            let updatedModel = context.model
            _ = FileManager.default
            // 生成されたモデルクラスからモデルのURLを取得
            guard let URLToModel = Bundle.main.url(forResource: "MobileNetV2_pytorch", withExtension: "mlmodelc") else {
                print("モデルファイルが見つかりません。")
                return
            }
            let newModelURL = URLToModel.deletingLastPathComponent().appendingPathComponent("MobileNetV2_pytorch.mlpackage")
            
            try updatedModel.write(to: newModelURL)
            // ここで新しいモデルのURLを保存し、次回の起動時にそれを使用するようにします
        } catch {
            print("Error saving updated model: \(error)")
        }
    }
    
}


struct RetrainingView_Previews: PreviewProvider {
    @State static var selectedImage = UIImage(named: "tops.png")
    static var previews: some View {
        RetrainingView(feedback: .constant("おしゃれ"), selectedImage: $selectedImage)
    }
}
