//
//  HackU2023App.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import GoogleMobileAds
import SwiftyUpdateKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                        GADMobileAds.sharedInstance().start(completionHandler: nil)
//                        update check https://github.com/HituziANDO/SwiftyUpdateKit
                        let config = SwiftyUpdateKitConfig(
                            // 現在のアプリバージョン
                            // 普通は以下の通りInfo.plistのバージョンを指定すれば良い
                            version: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
                            // iTunes ID
                            // iTunes IDはブラウザでApp Storeのアプリページを開いたときのURLから
                            // e.g.) App Store URL: "https://apps.apple.com/app/sampleapp/id1234567890" -> iTunesID is 1234567890
                            iTunesID: "6502258139",
                            // App StoreのアプリページのURL
                            storeURL: "https://apps.apple.com/app/kikonashi/id6502258139",
                            // iTunes Search APIで使う国コード
                            // http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
                            country: "jp",
                            // アプリバージョンの比較方法
                            // 省略したときはX.Y.Z形式のバージョンをstoreVersion > currentVersionかで比較します
                            versionCompare: VersionCompare(),
                            // アップデートアラートのタイトル
                            updateAlertTitle: "新しいバージョンがあります!",
                            // アップデートアラートのメッセージ
                            updateAlertMessage: "アプリをアップデートしてください。アップデート内容の詳細はApp Storeを参照してください。",
                            // アップデートアラートの更新ボタン
                            updateButtonTitle: "アップデート",
                            // アップデートアラートのキャンセルボタン
                            // nilを指定したときは非表示 -> キャンセル不可のためアップデートを強制します
                            remindMeLaterButtonTitle: "また後で",
                            retryCount: 2,
                            retryDelay: 1
                        )

                        // コンフィグをセットし初期化
                        // 第2引数のクロージャをセットしたときはフレームワークの内部ログを出力します
                        SUK.initialize(withConfig: config) { print($0) }

                        return true
                    }
    
}

@main
struct HackU2023App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
        WindowGroup {
            StartView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
