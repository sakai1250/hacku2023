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
    
    @ObservedObject private var weatherAPI = WeatherAPI()
    
    @State var isTrainingComplete = false
    @State var isActive = false
    @State var isTrainingInProgress = false

    @Binding var feedback: String
    @Binding var combinedImage: UIImage?
    @Binding var items: [String]
    @Binding var weather: String

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
//                    HStack {
//                        Spacer()
//                            .frame(height: screen.height / 2)
//                        Button("ホームへ") {
//                            isActive = true
//                        }
//                        .padding()
//                        .background(Color(red: 0.0, green: 0.6, blue: 0.9))
//                        .foregroundColor(.black)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                        .frame(maxWidth: screen.width / 2)
//                        .frame(maxHeight: screen.height / 5)
//                        .navigationDestination(isPresented: $isActive) {
//                            MainView()
//                        }
//                    }
//                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isActive) {
            MainView()
        }
        .onAppear {
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
                    if let model = selectModel_for_retrain(gender: gender, season: season, weather: weather) {
                        startRetraining(model: model)

                    }
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
    }
//  学習
    func startRetraining(model: String) {
        self.isTrainingInProgress = true
//        if self.feedback == "おしゃれじゃない" {
//            let newTrainingData: [TrainingData] = [
//                TrainingData(image: self.combinedImage!, label: self.feedback)
//            ]
//            let newFeatureProviders = newTrainingData.compactMap { createMLFeatureProvider(from: $0) }
//            let newData = MLArrayBatchProvider(array: newFeatureProviders)
//            print(newData)
//            retrainModel(with: newData, model: model)
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                self.isTrainingComplete = true
//                self.isActive = true
//                self.isTrainingInProgress = false
//            }
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.isTrainingComplete = true
            self.isActive = true
            self.isTrainingInProgress = false
        }
    }
    
//  学習
    func retrainModel(with newData: MLBatchProvider, model: String) {
        let modelConfiguration = MLModelConfiguration()
        modelConfiguration.computeUnits = .all // CPUとGPUの両方を使用
        modelConfiguration.allowLowPrecisionAccumulationOnGPU = true

        // 生成されたモデルクラスからモデルのURLを取得
        guard let modelURL = Bundle.main.url(forResource: model, withExtension: "mlmodelc")
        else {
            print("モデルファイルが見つかりません。")
            return
        }
        print("modelURL:\(modelURL)")
        let progressHandlers = MLUpdateProgressHandlers(forEvents: [.trainingBegin, .epochEnd]) { context in
            // 進捗イベントが発生したときの処理
            DispatchQueue.main.async {
                switch context.event {
                case .trainingBegin:
                    print("Training has started.")
                case .epochEnd:
                    print("An epoch has ended.")
                default:
                    break
                }
            }
        } completionHandler: { context in
            // トレーニングが完了したときの処理
            DispatchQueue.main.async {
                if let error = context.task.error {
                    print("モデル更新エラー: \(error.localizedDescription)")
                    return
                }
                if context.task.state == .completed {
                    print("context.task.state == .completed")
                    // ここにモデルの更新完了後の処理を追加
                    self.handleModelUpdate(context, model: model)
                    self.isTrainingComplete = true
                    self.isActive = true
                }
            }
        }
        let updateTask = try? MLUpdateTask(forModelAt: modelURL, trainingData: newData, configuration: modelConfiguration, progressHandlers: progressHandlers)
        updateTask?.resume()
    }

//  学習
    func handleModelUpdate(_ context: MLUpdateContext, model: String) {
        do {
            let updatedModel = context.model
            _ = FileManager.default
            // 生成されたモデルクラスからモデルのURLを取得
            guard let URLToModel = Bundle.main.url(forResource: model, withExtension: "mlmodelc") else {
                print("モデルファイルが見つかりません。")
                return
            }
            print("guard let URLToModel = Bundle.main.url(forResource: model, withExtension: mlmodelc")
            let newModelURL = URLToModel.deletingLastPathComponent().appendingPathComponent("\(model).mlpackage")
            try updatedModel.write(to: newModelURL)

        } catch {
            print("Error saving updated model: \(error)")
        }
    }
    
}


//struct RetrainingView_Previews: PreviewProvider {
//    @State static var selectedImage = UIImage(named: "tops.png")
//    static var previews: some View {
//        RetrainingView(feedback: .constant("おしゃれ"), combinedImage: $combinedImage)
//    }
//}
