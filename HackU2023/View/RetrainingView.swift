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
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var user: FetchedResults<ViViTUser>
    
    @State var isTrainingComplete = false
    @State var isActive = false
    @State var isTrainingInProgress = false
    @Binding var feedback: String
    @Binding var selectedImage: UIImage?
    @State private var items = ["", "", "", ""]

    @State private var retraining = true
    
    let screen: CGRect = UIScreen.main.bounds

    var body: some View {
        NavigationStack {
            ZStack {
                Image(items[3])
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                            .frame(height: screen.height / 2)
                        if isTrainingInProgress {
                            Button("ホームへ") {
                                isActive = true
                            }
                            .padding()
                            .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: screen.width / 2)
                            .frame(maxHeight: screen.height / 5)
                        }
                    }
                }
                .navigationDestination(isPresented: $isActive) {
                    MainView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            items = checkAndUpdateLevel(for: user.first!)
            startRetraining()
        }
    }
        
    func startRetraining() {
        self.isTrainingInProgress = true
        if self.feedback == "おしゃれじゃない" {
            let newTrainingData: [TrainingData] = [
                TrainingData(image: self.selectedImage!, label: self.feedback)
            ]
            let newFeatureProviders = newTrainingData.compactMap { createMLFeatureProvider(from: $0) }
            let newData = MLArrayBatchProvider(array: newFeatureProviders)
            retrainModel(with: newData)
        }
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
                    self.isActive = true
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
