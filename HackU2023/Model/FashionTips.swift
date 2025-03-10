//
//  FashionTips.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/09.
//

import Foundation


func printRandomString() -> String {
    let fashiontips: [String] = [
        "Iラインシルエットは上下が均等な形で、とてもシンプルなスタイルだよ。",

        "Aラインシルエットはボトムが太くなっていて、脚長効果が期待できるよ。",

       " Vラインシルエットはトップスがゆるっとした、定番のシルエットだよ。",

        "レイヤードは、異なる服を重ねることでスタイルの幅を広げるテクニックだよ。",

        "モノトーンは、単色や白黒を意味するよ。初心者にもおススメだよ。",

        "一般的に、コーディネートは3色までに抑えるのが無難といわれているよ。",

        "「差し色」はベースカラーと異なる反対色を一部に加える色だよ。",
    ]
    if let randomString = fashiontips.randomElement() {
        return randomString
    } else {
        return "配列が空です。"
    }
}
