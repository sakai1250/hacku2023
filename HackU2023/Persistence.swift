//
//  Persistence.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import CoreData

/// Core Dataスタックを管理するための`PersistenceController`クラス
struct PersistenceController {
    // プロジェクト全体で使用する共有インスタンス
    static let shared = PersistenceController()
//    static let shared: PersistenceController = {
//        // メモリ上で動作する永続化コントローラを作成
//        let controller = PersistenceController(inMemory: true)
//        let viewContext = controller.container.viewContext
//
//        let newUser = ViViTUser(context: viewContext)
////        newUser.name = nil
////        newUser.level = 1
////        newUser.exp = 0
//
//        // 変更を保存
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return controller
//    }()
    // プレビュー用のインスタンスを作成するためのプロパティ
    static var preview: PersistenceController = {
        // メモリ上で動作する永続化コントローラを作成
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // プレビュー用のデータを作成
        let newUser = ViViTUser(context: viewContext)
        newUser.name = "ビビっと"
        newUser.level = 1
        newUser.exp = 1
        newUser.gender = "男性"
        
        // 変更を保存
        do {
            try viewContext.save()
        } catch {
            // プレビューのためのエラーハンドリングは通常、単純なものでOKです。
            // 実際のアプリでは、ここでエラーを適切に処理する必要があります。
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return controller
    }()
    // Core Dataのコンテナ
    let container: NSPersistentContainer

    /// `NSPersistentContainer`を初期化し、データモデルを設定
    /// メモリ内でのテストのためには`inMemory`を`true`に設定
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HackU2023")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // 本番環境では適切なエラーハンドリングを実装
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// 新しい`User`インスタンスを作成し、与えられた情報を保存
    /// - Parameters:
    ///   - name: `User`の名前
    ///   - level: `User`のレベル
    ///   - imagePath: `User`の保存画像
    func saveUser(name: String, level: Int16, imagePath: String) {
        let viewContext = container.viewContext
        let user = ViViTUser(context: viewContext)
        user.name = name
        user.level = Int64(level)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            // エラーを適切に処理
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}
