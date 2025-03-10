//
//  AdsView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2024/05/20.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner) // インスタンスを生成
        // 諸々の設定をしていく
//        banner.adUnitID = "ca-app-pub-8954877192591804/8897975257"
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174" // テスト用
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            banner.rootViewController = window.rootViewController
        }
        banner.load(GADRequest())
        return banner // 最終的にインスタンスを返す
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // 特にないのでメソッドだけ用意
    }
}

