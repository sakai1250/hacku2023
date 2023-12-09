//
//  SettingView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import CoreData

struct SettingView: View {
    let items = ["プロフィール設定", "画像一覧の編集", "リセット"]
    @State private var navigateToStart = false
    @State private var showResetAlert = false
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                if item == "リセット" {
                    Button("リセット") {
                        showResetAlert = true
                    }
                } else {
                    NavigationLink(destination: Text(item)) {
                        Text(item)
                    }
                }
            }
            .navigationBarItems(trailing: Button("タイトル画面に戻る") {
                navigateToStart = true
            })
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("確認"),
                    message: Text("すべてのデータをリセットしますか？"),
                    primaryButton: .destructive(Text("リセット")) {
                        resetCoreData()
                        navigateToStart = true
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationDestination(isPresented: $navigateToStart) {
            StartView()
        }
        .navigationBarBackButtonHidden(true)

    }

    private func resetCoreData() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ViViTUser")
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)

        do {
            try viewContext.execute(deleteRequest1)
            viewContext.reset() // コンテキストをリセット
        } catch {
            let nsError = error as NSError
            // エラーを適切に処理してください。
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ImageEntity")
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)

        do {
            try viewContext.execute(deleteRequest2)
            viewContext.reset() // コンテキストをリセット
        } catch {
            let nsError = error as NSError
            // エラーを適切に処理してください。
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingView()
        }
    }
}

