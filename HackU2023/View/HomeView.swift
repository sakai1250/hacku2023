//
//  HomeView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI
import AVKit
import AVFoundation

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var users: FetchedResults<ViViTUser>
    @State private var showTutorial: Bool = false
    
    @ObservedObject private var weatherAPI = WeatherAPI()
    
    let screen: CGRect = UIScreen.main.bounds
    
    @StateObject var manager = ScreenShotManager()
    @State private var items = ["", "", "", ""]
    
    @State private var videoName: String = ""
    @State private var shouldPlayVideo = false
    @State private var shouldDismiss = false
    @State private var shouldDismiss_tutorial = false

    @State private var selectedTab: Tab = .home
    
    var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .topLeading) {
                    HStack(alignment: .center) {
                        Spacer()
                        ZStack() {
                            Image(items[0]) // 画像
                                .resizable()
                                .frame(maxWidth: screen.width / 0.9)
                                .frame(maxHeight: screen.height / 0.9)
                            Image(items[1]) // 画像
                                .resizable()
                                .aspectRatio(CGSize(width: 1, height: 2), contentMode:.fit)
                                .frame(maxWidth: screen.width * 2 / 3.5)
                                .frame(maxHeight: screen.height * 2 / 3)
                                .offset(y: screen.height / 7)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading)  {
                                if let data = weatherAPI.weatherData {
                                    if let weatherCode = data.weather.first?.main {
                                        let maxTemperature = data.main.temp_max
                                        let minTemperature = data.main.temp_min
                                        if weatherAPI.getWeatherCategory(from: weatherCode).rawValue != "不明" {
                                            Text("天気: \(weatherAPI.getWeatherCategory(from: weatherCode).rawValue)")
                                        }
                                        
                                        if maxTemperature <= 1000 {
                                            Text("最高気温: \(Int(round(maxTemperature))) °C")
                                            Text("最低気温: \(Int(round(minTemperature))) °C")
                                        }
                                    }
                                    //                                    Text("天気: \(weatherAPI.getWeatherCategory(weatherCode).rawValue)")
                                    //                                    Text("最高気温: \(Int(round(maxTemperature))) °C")
                                    //                                    Text("最低気温: \(Int(round(minTemperature))) °C")
                                } else {
                                    Text("データがありません")
                                }
                                //                            ForEach(users) { user in
                                //                                HStack {
                                //                                    VStack(alignment: .leading) { // VStackを左揃えに設定
                                //                                        Text("Name: \(user.name ?? "Unknown")")
                                //                                            .font(.headline)
                                //                                    }
                                //                                    Spacer() // 右側にスペースを追加して左揃えにする
                                //                                    VStack(alignment: .leading) {
                                //                                        Text("Level: \(user.level)")
                                //                                            .font(.subheadline)
                                //                                        Text("Exp: \(user.exp)")
                                //                                            .font(.subheadline)
                                //                                        ProgressView(value: Double(user.exp), total: 3) // 仮の最大値
                                //                                            .progressViewStyle(LinearProgressViewStyle())
                                //                                            .frame(width: 100)
                                //                                    }
                                //                                }
                                //                            }
                                ForEach(users) { user in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Name: \(user.name ?? "Unknown")")
                                                .font(.headline)
                                        }
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("Level: \(user.level)")
                                                .font(.subheadline)
                                            Text("Exp: \(user.exp)")
                                                .font(.subheadline)
                                            
                                            // 最大経験値を仮に定義
                                            let maxExp = 100.0
                                            // 経験値が最大値を超えないようにする
                                            let safeExp = min(Double(user.exp), maxExp)
                                            
                                            ProgressView(value: safeExp, total: maxExp)
                                                .progressViewStyle(LinearProgressViewStyle())
                                                .frame(width: 100)
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    manager.captureScreenShot(windowScene: UIApplication.shared.connectedScenes.first as? UIWindowScene, rect: manager.rect)
                                }){
                                    Text("共有")
                                }.sheet(isPresented: $manager.showActivityView) {
                                    ActivityView(
                                        activityItems: [manager.url],
                                        
                                        applicationActivities: nil
                                    )
                                }
                            }
                        }
                    }
                }
                if shouldPlayVideo {
                    VideoPlayerView(videoName: videoName, shouldDismiss: $shouldDismiss)
                        .onAppear {
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                                shouldDismiss = true
                                shouldPlayVideo = false
                            }
                        }
                }
            }
        }
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
                            try managedObjectContext.save()
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
                        try managedObjectContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
        }

        .sheet(isPresented: $shouldPlayVideo) {
            VideoPlayerView(videoName: videoName, shouldDismiss: $shouldDismiss)
        }
        .onAppear {
            let updateResults = checkAndUpdateLevel(for: users.first!)
            videoName = updateResults.last ?? ""
            items = updateResults
            shouldPlayVideo = !videoName.isEmpty
        }
        .background(RectangleGetter(rect: $manager.rect))
    }
}
