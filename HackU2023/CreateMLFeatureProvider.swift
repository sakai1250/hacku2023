//
//  CreateMLFeatureProvider.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import CoreML
import UIKit

// トレーニングデータの例（画像とラベル）
struct TrainingData {
    var image: UIImage
    var label: String
}

func createMLFeatureProvider(from data: TrainingData) -> MLFeatureProvider? {
    // 画像をMLFeatureValueに変換
    guard let pixelBuffer = data.image.toCVPixelBuffer() else {
        return nil
    }

    // ラベルをMLFeatureValueに変換
    let labelFeatureValue = MLFeatureValue(string: data.label)

    // モデルの入力名に合わせてキーを設定
    let featureProvider = try? MLDictionaryFeatureProvider(dictionary: [
        "image": pixelBuffer,
        "label": labelFeatureValue
    ])

    return featureProvider
}
