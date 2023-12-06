//
//  HomeView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var users: FetchedResults<ViViTUser>
    
    @ObservedObject private var weatherAPI = WeatherAPI()
    
    let screen: CGRect = UIScreen.main.bounds
    
    @StateObject var manager = ScreenShotManager()
    @State private var items = ["", "", "", ""]

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) { // 左上に配置
                HStack(alignment: .center) {
                    Spacer()
                    ZStack() {
                        Image(items[0]) // 画像
                            .resizable()
                            .frame(maxWidth: screen.width / 0.9)
                            .frame(maxHeight: screen.height / 0.9)
                        Image(items[1]) // 画像
                            .resizable()
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
                                if let weatherCode = data.daily.weather_code.first,
                                   let maxTemperature = data.daily.temperature_2m_max.first,
                                   let minTemperature = data.daily.temperature_2m_min.first {
                                    Text("天気: \(weatherAPI.getWeatherCategory(weatherCode).rawValue)")
                                    Text("最高気温: \(Int(round(maxTemperature))) °C")
                                    Text("最低気温: \(Int(round(minTemperature))) °C")
                                }
                            } else {
                                Text("データがありません")
                            }
                            ForEach(users) { user in
                                HStack {
                                    VStack(alignment: .leading) { // VStackを左揃えに設定
                                        Text("Name: \(user.name ?? "Unknown")")
                                            .font(.headline)
                                    }
                                    Spacer() // 右側にスペースを追加して左揃えにする
                                    VStack(alignment: .leading) {
                                        Text("Level: \(user.level)")
                                            .font(.subheadline)
                                        Text("Exp: \(user.exp)")
                                            .font(.subheadline)
                                        ProgressView(value: Double(user.exp), total: 3) // 仮の最大値
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
            .onAppear {
                items = checkAndUpdateLevel(for: users.first!)
            }
        .background(RectangleGetter(rect: $manager.rect))
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
