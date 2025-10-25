//  WeatherForecast
//  CCLocationManager
//  Created by Tharun Menon on 24/10/25.

import Foundation
import CoreLocation
import Combine

final class CCLocationManager: NSObject, ObservableObject {
    @Published var m_lastLocation: CLLocationCoordinate2D?
    @Published var m_authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let m_manager = CLLocationManager()

    override init() {
        super.init()
        m_manager.delegate = self
        m_manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        // Location Permission
        let current = CLLocationManager.authorizationStatus()
        switch current {
        case .notDetermined:
            m_manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            m_manager.requestLocation()
        default:
            // trigger an authorization prompt in case it's restricted/denied
            m_manager.requestWhenInUseAuthorization()
        }
    }
}

extension CCLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        DispatchQueue.main.async {
            print("[CCLocationManager] didUpdateLocations: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            self.m_lastLocation = loc.coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // handle gracefully in production
        print("Location error: \\((error))")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        m_authorizationStatus = manager.authorizationStatus
        print("[CCLocationManager] authorization changed: \(m_authorizationStatus.rawValue)")
        if m_authorizationStatus == .authorizedWhenInUse || m_authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
