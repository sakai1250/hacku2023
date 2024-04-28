//
//  FullconnectionLayer.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2024/03/30.
//

import SwiftUI
import Foundation
import CoreML
import CoreData

// 全結合のクラス定義
class FullyConnectedNetwork {
    @Environment(\.managedObjectContext) private var viewContext

    var weights: [[Double]]
    var biases: [Double]
    var first: Bool?
    
    init(inputChannels: Int, outputChannels: Int, user: ViViTUser) {
        weights = firstFullConnectWeights()
        biases = firstFullConnectBiases()
        initfc(inputChannels: 64, outputChannels: 2, user: user)
    }

    func initfc(inputChannels: Int, outputChannels: Int, user: ViViTUser) {
        // 既存のユーザー設定を更新
        first = user.first_sp
        if first ?? true {
            print("FirstFirstFirstFirst")
            weights = firstFullConnectWeights()
            biases = firstFullConnectBiases()
            user.first_sp = false
            user.fullconne_sp_w = weights as NSObject
            user.fullconne_sp_b = biases as NSObject
        } else {
            weights = user.fullconne_sp_w as! [[Double]]
            biases = user.fullconne_sp_b as! [Double]
        }
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
    func train(inputs: [Double], trueOutputs: [Double], learningRate: Double, epochs: Int) {
        for _ in 1...epochs {
//            for (input, trueOutput) in zip(inputs, trueOutputs) {
//                updateParameters(input: input, trueOutput: trueOutput, learningRate: learningRate)
//            }
            updateParameters(input: inputs, trueOutput: trueOutputs, learningRate: learningRate)
        }
    }
    
    // 推論関数
    func infer(input: [Double]) -> [Double] {
        return predict(input: input)
    }
    

}
