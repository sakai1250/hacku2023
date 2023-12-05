//
//  ViewController.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI

struct MainView: View {
    @State var selection = 1

    var body: some View {
        // 下部のタブビュー
        TabView(selection: $selection) {
            
            HomeView()
                .tabItem {
                    Label("HOME", systemImage: "1.circle")
                }
                .tag(1)
            
            PickImageView()
                .tabItem {
                    Label("診断", systemImage: "2.circle")
                }
                .tag(2)
            
            EditPhotosView()
                .tabItem {
                    Label("画像一覧", systemImage: "3.circle")
                }
                .tag(3)
            
            SettingView()
                .tabItem {
                    Label("設定", systemImage: "3.circle")
                }
                .tag(4)
            
        }
        .navigationBarBackButtonHidden(true)
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
