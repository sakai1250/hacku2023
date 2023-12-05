import SwiftUI
import Foundation

struct WeatherInfo: Codable {
    let latitude: Double
    let longitude: Double
    let generationtime_ms: Double
    let utc_offset_seconds: Int
    let timezone: String
    let timezone_abbreviation: String
    let elevation: Int
    let daily_units: DailyUnits
    let daily: Daily
}

struct DailyUnits: Codable {
    let time: String
    let weather_code: String
    let temperature_2m_max: String
    let temperature_2m_min: String
}

struct Daily: Codable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
}

class WeatherAPI: ObservableObject {
    @Published var weatherData: WeatherInfo?
    
    init() {
        getLocationAndFetchData()
    }
    
    // 天気のカテゴリを定義
    enum WeatherCategory: String {
        case clearSky = "晴れ"
        case rain = "雨"
        case cloudy = "曇り"
        case snow = "雪"
        case thunderstorm = "雷雨"
        case unknown = "不明"
    }
    
    // 天気カテゴリを取得する関数
    public func getWeatherCategory(_ weatherCode: Int) -> WeatherCategory {
        switch weatherCode {
        case 0:
            return .clearSky
        case 1, 2, 3:
            return .clearSky
        case 45, 48:
            return .cloudy
        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
            return .rain
        case 71, 73, 75, 77, 85, 86:
            return .snow
        case 95, 96, 99:
            return .thunderstorm
        default:
            return .unknown
        }
    }
    
    private func getLocationAndFetchData() {
        // 位置情報を取得
        LocationManager.shared.getLocation { result in
            switch result {
            case .success(let location):
                // 現在の緯度と経度を使用してAPIリクエストを作成
                let latitude = location.latitude
                let longitude = location.longitude
                let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=1")!
                
                // APIリクエストを送信
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let decodedData = try decoder.decode(WeatherInfo.self, from: data)
                            DispatchQueue.main.async {
                                self.weatherData = decodedData
                            }
                        } catch {
                            print("データのデコードエラー: \(error)")
                        }
                    } else if let error = error {
                        print("APIリクエストエラー: \(error)")
                    }
                }.resume()
            case .failure(let error):
                print("位置情報取得エラー: \(error)")
            }
        }
    }
}
