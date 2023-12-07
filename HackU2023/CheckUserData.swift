//
//  CheckUserData.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/05.
//

import Foundation
import Vision

func checkAndUpdateLevel(for user: ViViTUser) -> [String] {
    var room: String = "Room"
    var avater: String = ""
    var assume: String = "Hacku_thinking"
    var retrain: String = "Hacku_learning"

    if user.exp == 3 {
        user.level += 1
        user.exp = 0
    }
    else if user.exp == 5 {
        user.level += 1
        user.exp = 0
    }
    
    if user.level == 1 {
        if user.gender == "男性" {
            room = "\(room)M"
            avater = "Male1"
            assume = "\(assume)1"
            retrain = "\(retrain)1"

        }
        else if user.gender == "女性" {
            room = "\(room)F"
            avater = "Female1"
            assume = "\(assume)0"
            retrain = "\(retrain)0"

        }

    }

    else if user.level == 2 {
        if user.gender == "男性" {
            room = "\(room)M"
            avater = "Male2"
            assume = "\(assume)3"
            retrain = "\(retrain)3"

        }
        else if user.gender == "女性" {
            room = "\(room)F"
            avater = "Female2"
            assume = "\(assume)2"
            retrain = "\(retrain)2"

            
        }

    }

    else if user.level >= 3 {
        if user.gender == "男性" {
            room = "\(room)M"
            avater = "Male3"
            assume = "\(assume)5"
            retrain = "\(retrain)5"

            
        }
        else if user.gender == "女性" {
            room = "\(room)F"
            avater = "Female3"
            assume = "\(assume)4"
            retrain = "\(retrain)4"
            
        }

    }
    return [room, avater, assume, retrain]
}


func selectModel(gender: String, season: String, weather: String) -> VNCoreMLModel? {
    switch (gender, season, weather) {
    // 男性の組み合わせ
    case ("男性", "春", "晴れ"):
        return try? VNCoreMLModel(for: spring_sunny_Man().model)
//    case ("男性", "春", "雨"):
//        return try? VNCoreMLModel(for: spring_rainy_Man().model)
//    case ("男性", "夏", "晴れ"):
//        return try? VNCoreMLModel(for: summer_sunny_Man().model)
//    case ("男性", "夏", "雨"):
//        return try? VNCoreMLModel(for: summer_rainy_Man().model)
//    case ("男性", "秋", "晴れ"):
//        return try? VNCoreMLModel(for: autumn_sunny_Man().model)
//    case ("男性", "秋", "雨"):
//        return try? VNCoreMLModel(for: autumn_rainy_Man().model)
    case ("男性", "冬", "晴れ"):
        return try? VNCoreMLModel(for: winter_sunny_Man().model)
//    case ("男性", "冬", "雨"):
//        return try? VNCoreMLModel(for: winter_rainy_Man().model)

    // 女性の組み合わせ
    case ("女性", "春", "晴れ"):
        return try? VNCoreMLModel(for: spring_sunny_Woman().model)
//    case ("女性", "春", "雨"):
//        return try? VNCoreMLModel(for: spring_rainy_Woman().model)
//    case ("女性", "夏", "晴れ"):
//        return try? VNCoreMLModel(for: summer_sunny_Woman().model)
//    case ("女性", "夏", "雨"):
//        return try? VNCoreMLModel(for: summer_rainy_Woman().model)
//    case ("女性", "秋", "晴れ"):
//        return try? VNCoreMLModel(for: autumn_sunny_Woman().model)
//    case ("女性", "秋", "雨"):
//        return try? VNCoreMLModel(for: autumn_rainy_Woman().model)
    case ("女性", "冬", "晴れ"):
        return try? VNCoreMLModel(for: winter_sunny_Woman().model)
//    case ("女性", "冬", "雨"):
//        return try? VNCoreMLModel(for: winter_rainy_Woman().model)

    default:
        return try? VNCoreMLModel(for: MobileNetV2_pytorch().model)
    }
}


