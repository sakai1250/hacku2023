//
//  ViewController.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI


enum Tab {
    case home
    case pickimage
    case editphoto
    case settings
}

class TabViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
}

struct MainView: View {
//    @State var selection = 1
//    @State private var selectedTab: Tab = .home
//    @Binding var selectedTab: Tab
    @StateObject private var viewModel = TabViewModel()

    let tabHeight = UIScreen.main.bounds.height * 0.08
    let tabWidth = UIScreen.main.bounds.width
    let iconHeight = UIScreen.main.bounds.height * 0.08
    let iconWidth = UIScreen.main.bounds.width * 0.25 * 0.7

    var body: some View {
        // コンテンツ
        VStack {
            switch viewModel.selectedTab {
            case .home:
                HomeView()
            case .pickimage:
                SelectFunctionView()
            case .editphoto:
                AlbamView()
            case .settings:
                SettingView()
            }
            VStack {
                // タブバー
                HStack {
                    Spacer()

                    Button(action: { viewModel.selectedTab = .home }) {
                        Image("hacku_button5")
                            .resizable()
                            .frame(width: iconWidth, height: iconHeight)
                    }
                    Spacer()

                    Button(action: { viewModel.selectedTab = .pickimage }) {
                        Image("hacku_button4")
                            .resizable()
                            .frame(width: iconWidth, height: iconHeight)
                    }
                    Spacer()

                    Button(action: { viewModel.selectedTab = .editphoto }) {
                        Image("hacku_button2")
                            .resizable()
                            .frame(width: iconWidth, height: iconHeight)
                    }
                    Spacer()

                    Button(action: { viewModel.selectedTab = .settings }) {
                        Image("hacku_button1")
                            .resizable()
                            .frame(width: iconWidth, height: iconHeight)
                    }
                    Spacer()

                }
                .frame(width: tabWidth, height: tabHeight)
                .background(.brown)
            }
            .onAppear {
                viewModel.selectedTab = .home
            }

        }
        .navigationBarBackButtonHidden(true)
    }
}
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(selectedTab: .home)
//    }
//}
