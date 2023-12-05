//
//  CheckUserData.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/05.
//

import Foundation

func checkAndUpdateLevel(for user: ViViTUser) -> [String] {
    var room: String = "Room"
    var avater: String = ""

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
        }
        else if user.gender == "女性" {
            room = "\(room)F"
            avater = "Female1"
            
        }

    }

    else if user.level == 2 {
        if user.gender == "男性" {
            room = "\(room)M"
            avater = "Male2"
        }
        else if user.gender == "女性" {
            room = "\(room)F"
            avater = "Female2"
            
        }

    }

    else if user.level >= 3 {
        if user.gender == "男性" {
            room = "\(room)M"
            avater = "Male3"
            
        }
        else if user.gender == "女性" {
            room = "\(room)F"
            avater = "Female3"
            
        }

    }
    print(room)

    return [room, avater]
}
