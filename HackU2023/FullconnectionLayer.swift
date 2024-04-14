//
//  FullconnectionLayer.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2024/03/30.
//

import Foundation
import CoreML

// MLMultiArrayからDouble型の配列へ変換する関数
func convertToDoubleArray(from multiArray: MLMultiArray) -> [Double] {
    var doubleArray: [Double] = []
    let length = multiArray.count
    for i in 0..<length {
        doubleArray.append(Double(truncating: multiArray[i]))
    }
    return doubleArray
}

//// 例：MLMultiArrayの生成と変換
//let inputMultiArray = try MLMultiArray(shape: [64], dataType: .float32)
//// MLMultiArrayに何らかの値を設定...
//let inputDoubleArray = convertToDoubleArray(from: inputMultiArray)
//



// 全結合のクラス定義
class FullyConnectedNetwork {
    var weights: [[Double]]
    var biases: [Double]
    
    init(inputChannels: Int, outputChannels: Int) {
        // 重みとバイアスの初期化
        weights = (0..<inputChannels).map { _ in (0..<outputChannels).map { _ in Double.random(in: -1.0...1.0) } }
        biases = (0..<outputChannels).map { _ in Double.random(in: -1.0...1.0) }
    }
    
    // ネットワークの予測関数
    func predict(input: [Double]) -> [Double] {
        var output = [Double](repeating: 0.0, count: biases.count)
        for i in 0..<weights[0].count {
            for j in 0..<weights.count {
                output[i] += input[j] * weights[j][i]
            }
            output[i] += biases[i]
        }
        return output
    }
    
    // パラメータの更新関数
    func updateParameters(input: [Double], trueOutput: [Double], learningRate: Double) {
        let predictedOutput = predict(input: input)
        for i in 0..<weights[0].count {
            let error = predictedOutput[i] - trueOutput[i]
            for j in 0..<weights.count {
                let gradientWeight = error * input[j]
                weights[j][i] -= learningRate * gradientWeight
            }
            let gradientBias = error
            biases[i] -= learningRate * gradientBias
        }
    }
    
    // 学習関数
    func train(inputs: [[Double]], trueOutputs: [[Double]], learningRate: Double, epochs: Int) {
        for epoch in 1...epochs {
            for (input, trueOutput) in zip(inputs, trueOutputs) {
                updateParameters(input: input, trueOutput: trueOutput, learningRate: learningRate)
            }
        }
    }
    
    // 推論関数
    func infer(input: [Double]) -> [Double] {
        return predict(input: input)
    }
}
//MultiArray (Float32 1 × 64)
//// 使用例
//let model = FullyConnectedNetwork(inputChannels: 64, outputChannels: 2)
//
//// 仮の学習データ
//let inputs = (0..<5).map { _ in (0..<64).map { _ in Double.random(in: -1.0...1.0) } }
//let trueOutputs = [[0.5, -0.5], [0.4, -0.4], [0.3, -0.3], [0.2, -0.2], [0.1, -0.1]]
//let learningRate: Double = 0.01
//let epochs: Int = 100
//
//// 学習プロセス
//model.train(inputs: inputs, trueOutputs: trueOutputs, learningRate: learningRate, epochs: epochs)
//
//// 新しい入力データに対する推論
//let newInput = (0..<64).map { _ in Double.random(in: -1.0...1.0) }
//let prediction = model.infer(input: newInput)
//print("推論結果: \(prediction)")

