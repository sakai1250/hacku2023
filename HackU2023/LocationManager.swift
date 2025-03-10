//
//  LocationManager.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/04.
//

import SwiftUI
import CoreLocation


// ユーザーに位置情報アクセス許可をリクエスト
let locationManager = CLLocationManager()

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
//    private var locationManager = CLLocationManager()
    let locationManager = CLLocationManager()

    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    override private init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func getLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        if let location = self.locationManager.location {
            let coordinates = location.coordinate
            completion(.success(coordinates))
        } else {
            completion(.failure(NSError(domain: "Location Error", code: 0, userInfo: nil)))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}
