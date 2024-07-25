//
//  SetupView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/04.
//

import SwiftUI

enum Gender: String, CaseIterable, Identifiable {
    case none = "選択してください"
    case male = "男性"
    case female = "女性"
    
    var id: String { self.rawValue }
}

struct SetupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var userSettings: FetchedResults<ViViTUser>
    
    @State private var username: String = ""
    @State private var selectedGender: Gender = .none
    @State private var selectedGenderAvater: Gender = .none

    @State private var isActive = false
    @State private var showResetAlert = false
    @State private var selectedTab: Tab = .home

    var body: some View {
        NavigationStack {
            Form {
                TextField("キャラ名", text: $username)
                Picker("あなたの性別", selection: $selectedGender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // ドロップダウンスタイル
                
                Picker("キャラの性別", selection: $selectedGenderAvater) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // ドロップダウンスタイル

                Button("設定完了") {
                    if selectedGender != .none {
                        addOrUpdateUserSetting()
                        isActive = true
                    } else {
                        showResetAlert = true
                    }
                }
                .alert(isPresented: $showResetAlert) {
                    Alert(
                        title: Text("確認"),
                        message: Text("性別が選択されていません"),
                        dismissButton: .cancel()
                    )
                }
            }
            .navigationDestination(isPresented: $isActive) {
                MainView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func addOrUpdateUserSetting() {
        let userSetting: ViViTUser
        if let existingUserSetting = userSettings.first {
            // 既存のユーザー設定を更新
            userSetting = existingUserSetting
        } else {
            // 新しいユーザー設定を作成
            userSetting = ViViTUser(context: viewContext)
            userSetting.level = 1
            userSetting.exp = 0
        }

        userSetting.name = username
        userSetting.gender = selectedGender.rawValue
        userSetting.gender_avater = selectedGenderAvater.rawValue

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

