import SwiftUI
import Foundation

//struct WeatherInfo: Codable {
//    let latitude: Double
//    let longitude: Double
//    let generationtime_ms: Double
//    let utc_offset_seconds: Int
//    let timezone: String
//    let timezone_abbreviation: String
//    let elevation: Int
//    let daily_units: DailyUnits
//    let daily: Daily
//}
//
//struct DailyUnits: Codable {
//    let time: String
//    let weather_code: String
//    let temperature_2m_max: String
//    let temperature_2m_min: String
//}
//
//struct Daily: Codable {
//    let time: [String]
//    let weather_code: [Int]
//    let temperature_2m_max: [Double]
//    let temperature_2m_min: [Double]
//}

struct WeatherInfo: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int

    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }

    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Int
        let humidity: Int
        let sea_level: Int?
        let grnd_level: Int?
    }

    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double?
    }

    struct Clouds: Codable {
        let all: Int
    }

    struct Sys: Codable {
        let type: Int
        let id: Int
        let country: String
        let sunrise: Int
        let sunset: Int
    }
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
    public func getWeatherCategory(from weatherDescription: String) -> WeatherCategory {
        switch weatherDescription {
        case "Thunderstorm":
            return .thunderstorm
        case "Drizzle":
            return .rain
        case "Rain":
            return .rain
        case "Snow":
            return .snow
        case "Clear":
            return .clearSky
        case "Clouds":
            return .cloudy
        case "Fog":
            return .cloudy
        default:
            return .unknown
        }
    }
//    // 天気カテゴリを取得する関数
//    public func getWeatherCategory(_ weatherCode: Int) -> WeatherCategory {
//        switch weatherCode {
//        case 0:
//            return .clearSky
//        case 1, 2, 3:
//            return .clearSky
//        case 45, 48:
//            return .cloudy
//        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
//            return .rain
//        case 71, 73, 75, 77, 85, 86:
//            return .snow
//        case 95, 96, 99:
//            return .thunderstorm
//        default:
//            return .unknown
//        }
//    }
//
    
    
    // 天気カテゴリを取得する関数
    public func getWeatherCategory_for_predict(_ weatherCategory: String) -> String {
        switch weatherCategory {
        case "晴れ":
            return "晴れ"
        case "曇り":
            return "晴れ"
        case "雨":
            return "雨"
        case "雷雨":
            return "雨"
        case "雪":
            return "雨"
        default:
            return "不明"
        }
    }
    
//    private func getLocationAndFetchData() {
//        // 位置情報を取得
//        LocationManager.shared.getLocation { result in
//            switch result {
//            case .success(let location):
//                // 現在の緯度と経度を使用してAPIリクエストを作成
//                let latitude = location.latitude
//                let longitude = location.longitude
////                let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=1")!
//                let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=b39a2a2623dc3a950cfa43de28802916")!
//                // APIリクエストを送信
//                URLSession.shared.dataTask(with: url) { data, _, error in
//                    if let data = data {
//                        do {
//                            let decoder = JSONDecoder()
//                            let decodedData = try decoder.decode(WeatherInfo.self, from: data)
//                            DispatchQueue.main.async {
//                                self.weatherData = decodedData
//                            }
//                        } catch {
//                            print("データのデコードエラー: \(error)")
//                        }
//                    } else if let error = error {
//                        print("APIリクエストエラー: \(error)")
//                    }
//                }.resume()
//            case .failure(let error):
//                print("位置情報取得エラー: \(error)")
//            }
//        }
//    }
//}

    private func getLocationAndFetchData() {
        // 位置情報を取得
        LocationManager.shared.getLocation { result in
            switch result {
            case .success(let location):
                // 現在の緯度と経度を使用してAPIリクエストを作成
                let latitude = location.latitude
                let longitude = location.longitude
                let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=b39a2a2623dc3a950cfa43de28802916")!
                // APIリクエストを送信
                URLSession.shared.dataTask(with: url) { data, _, error in
                    DispatchQueue.main.async {
                        if let data = data {
                            do {
                                let decoder = JSONDecoder()
                                let decodedData = try decoder.decode(WeatherInfo.self, from: data)
                                self.weatherData = decodedData
                            } catch {
                                print("データのデコードエラー: \(error)")
                                self.setDefaultWeatherData()
                            }
                        } else if let error = error {
                            print("APIリクエストエラー: \(error)")
                            self.setDefaultWeatherData()
                        } else {
                            print("不明なエラー")
                            self.setDefaultWeatherData()
                        }
                    }
                }.resume()
            case .failure(let error):
                print("位置情報取得エラー: \(error)")
                DispatchQueue.main.async {
                    self.setDefaultWeatherData()
                }
            }
        }
    }

    private func setDefaultWeatherData() {
        let defaultWeather = WeatherInfo(
            coord: WeatherInfo.Coord(lon: 0, lat: 0),
            weather: [WeatherInfo.Weather(id: 800, main: "不明", description: "不明", icon: "01d")],
            base: "stations",
            main: WeatherInfo.Main(temp: 99999, feels_like: 99999, temp_min: 99999, temp_max: 99999, pressure: 99999, humidity: 99999, sea_level: 99999, grnd_level: 99999),
            visibility: 10000,
            wind: WeatherInfo.Wind(speed: 1.5, deg: 0, gust: nil),
            clouds: WeatherInfo.Clouds(all: 0),
            dt: Int(Date().timeIntervalSince1970),
            sys: WeatherInfo.Sys(type: 1, id: 1, country: "JP", sunrise: Int(Date().timeIntervalSince1970), sunset: Int(Date().timeIntervalSince1970 + 43200)),
            timezone: 32400,
            id: 1,
            name: "Default City",
            cod: 200
        )
        self.weatherData = defaultWeather
    }
}

func seasonFromDates(_ dateStrings: [String]) -> String {
    func seasonForMonth(_ month: Int) -> String {
        switch month {
        case 3...5:
            return "春"
        case 6...8:
            return "夏"
        case 9...11:
            return "秋"
        case 12, 1...2:
            return "冬"
        default:
            return "不明な季節"
        }
    }

    if let firstDateString = dateStrings.first,
       let monthString = firstDateString.split(separator: "-").dropFirst().first,
       let month = Int(monthString) {
        return seasonForMonth(month)
    } else {
        return "不明な季節"
    }
}
