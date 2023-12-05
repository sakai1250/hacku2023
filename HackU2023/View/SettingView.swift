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
            .navigationTitle("設定")
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
    }

    private func resetCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ViViTUser")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
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

