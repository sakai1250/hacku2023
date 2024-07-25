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
    
    init(inputChannels: Int, outputChannels: Int, user: ViViTUser, gender: String, season: String, weather: String) {
        weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
        biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
        initfc(inputChannels: 64, outputChannels: 2, user: user, gender: gender, season: season, weather: weather)
    }
    
    func initfc(inputChannels: Int, outputChannels: Int, user: ViViTUser, gender: String, season: String, weather: String) {
        // 既存のユーザー設定を更新
        first = selectFC(gender: gender, season: season, weather: weather, user: user)
        switch (gender, season, weather) {
        case ("男性", "春", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sp_m_s = false
                user.fullconne_w_spms = weights as NSObject
                user.fullconne_b_spms = biases as NSObject
            } else {
                weights = user.fullconne_w_spms as! [[Double]]
                biases = user.fullconne_b_spms as! [Double]
            }
        case ("男性", "夏", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sm_m_s = false
                user.fullconne_w_smms = weights as NSObject
                user.fullconne_b_smms = biases as NSObject
            } else {
                weights = user.fullconne_w_smms as! [[Double]]
                biases = user.fullconne_b_smms as! [Double]
            }
        case ("男性", "秋", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_fl_m_s = false
                user.fullconne_w_fms = weights as NSObject
                user.fullconne_b_fms = biases as NSObject
            } else {
                weights = user.fullconne_w_fms as! [[Double]]
                biases = user.fullconne_b_fms as! [Double]
            }
        case ("男性", "冬", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_wi_m_s = false
                user.fullconne_w_wms = weights as NSObject
                user.fullconne_b_wms = biases as NSObject
            } else {
                weights = user.fullconne_w_wms as! [[Double]]
                biases = user.fullconne_b_wms as! [Double]
            }

        case ("女性", "春", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sp_w_s = false
                user.fullconne_w_spws = weights as NSObject
                user.fullconne_b_spws = biases as NSObject
            } else {
                weights = user.fullconne_w_spws as! [[Double]]
                biases = user.fullconne_b_spws as! [Double]
            }
        case ("女性", "夏", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sm_w_s = false
                user.fullconne_w_smws = weights as NSObject
                user.fullconne_b_smws = biases as NSObject
            } else {
                weights = user.fullconne_w_smws as! [[Double]]
                biases = user.fullconne_b_smws as! [Double]
            }
        case ("女性", "秋", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_fl_w_s = false
                user.fullconne_w_fws = weights as NSObject
                user.fullconne_b_fws = biases as NSObject
            } else {
                weights = user.fullconne_w_fws as! [[Double]]
                biases = user.fullconne_b_fws as! [Double]
            }
        case ("女性", "冬", "晴れ"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_wi_w_s = false
                user.fullconne_w_wws = weights as NSObject
                user.fullconne_b_wws = biases as NSObject
            } else {
                weights = user.fullconne_w_wws as! [[Double]]
                biases = user.fullconne_b_wws as! [Double]
            }

        case ("男性", "春", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sp_m_r = false
                user.fullconne_w_spmr = weights as NSObject
                user.fullconne_b_spmr = biases as NSObject
            } else {
                weights = user.fullconne_w_spmr as! [[Double]]
                biases = user.fullconne_b_spmr as! [Double]
            }
        case ("男性", "夏", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sm_m_r = false
                user.fullconne_w_smmr = weights as NSObject
                user.fullconne_b_smmr = biases as NSObject
            } else {
                weights = user.fullconne_w_smmr as! [[Double]]
                biases = user.fullconne_b_smmr as! [Double]
            }
        case ("男性", "秋", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_fl_m_r = false
                user.fullconne_w_fmr = weights as NSObject
                user.fullconne_b_fmr = biases as NSObject
            } else {
                weights = user.fullconne_w_fmr as! [[Double]]
                biases = user.fullconne_b_fmr as! [Double]
            }
        case ("男性", "冬", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_wi_m_r = false
                user.fullconne_w_wmr = weights as NSObject
                user.fullconne_b_wmr = biases as NSObject
            } else {
                weights = user.fullconne_w_wmr as! [[Double]]
                biases = user.fullconne_b_wmr as! [Double]
            }

        case ("女性", "春", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sp_w_r = false
                user.fullconne_w_spwr = weights as NSObject
                user.fullconne_b_spwr = biases as NSObject
            } else {
                weights = user.fullconne_w_spwr as! [[Double]]
                biases = user.fullconne_b_spwr as! [Double]
            }
        case ("女性", "夏", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sm_w_r = false
                user.fullconne_w_smwr = weights as NSObject
                user.fullconne_b_smwr = biases as NSObject
            } else {
                weights = user.fullconne_w_smwr as! [[Double]]
                biases = user.fullconne_b_smwr as! [Double]
            }
        case ("女性", "秋", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_fl_w_r = false
                user.fullconne_w_fwr = weights as NSObject
                user.fullconne_b_fwr = biases as NSObject
            } else {
                weights = user.fullconne_w_fwr as! [[Double]]
                biases = user.fullconne_b_fwr as! [Double]
            }
        case ("女性", "冬", "雨"):
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_wi_w_r = false
                user.fullconne_w_wwr = weights as NSObject
                user.fullconne_b_wwr = biases as NSObject
            } else {
                weights = user.fullconne_w_wwr as! [[Double]]
                biases = user.fullconne_b_wwr as! [Double]
            }


        default:
            if first ?? true {
                weights = firstFullConnectWeights(gender: gender, season: season, weather: weather)
                biases = firstFullConnectBiases(gender: gender, season: season, weather: weather)
                user.first_sp_m_s = false
                user.fullconne_w_spms = weights as NSObject
                user.fullconne_b_spms = biases as NSObject
            } else {
                weights = user.fullconne_w_spms as! [[Double]]
                biases = user.fullconne_b_spms as! [Double]
            }
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
