//
//  SettingView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI

struct SettingView: View {
    let items = ["プロフィール設定", "画像一覧の編集", "リセット"]
    
    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                NavigationLink() {
                    Text(item)
                }label: {
                    Text(item)
                }
            }
        }.navigationTitle("設定")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
