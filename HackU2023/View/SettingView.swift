//
//  SettingView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import CoreData

struct SettingView: View {
    let items = ["プロフィール変更", "リセット", "チュートリアルを見る"]
    @State private var navigateToStart = false
    @State private var navigateToSetup = false
    @State private var showResetAlert = false
    @State private var shouldDismiss_tutorial = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var users: FetchedResults<ViViTUser>
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                if item == "プロフィール変更" {
                    Button("プロフィール変更") {
                        navigateToSetup = true
                    }
                }
                else if item == "リセット" {
                    Button("リセット") {
                        showResetAlert = true
                    }
                }
                else if item == "チュートリアルを見る" {
                    Button("チュートリアルを見る") {
                        shouldDismiss_tutorial = true
                        users.first?.tutrial = true
                    }
                }
                else {
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
        .navigationDestination(isPresented: $navigateToSetup) {
            SetupView()
        }
        .navigationBarBackButtonHidden(true)
        
        // チュートリアル表示の条件を修正
        .sheet(isPresented: Binding<Bool>(
            get: { users.first?.tutrial ?? true }, // チュートリアル表示の条件
            set: { if !$0 { shouldDismiss_tutorial = true } } // 閉じる際の処理
        )) {
            VideoPlayerView(videoName: "movies/tutorial.mp4", shouldDismiss: $shouldDismiss_tutorial)
                .ignoresSafeArea()
                .onAppear {
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                        shouldDismiss_tutorial = true
                        users.first?.tutrial = false
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
                .onDisappear {
                    shouldDismiss_tutorial = true
                    users.first?.tutrial = false
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
        }
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

