
//  WeatherForecast
//  CCForecastViewModel
//  Created by Tharun Menon on 24/10/25.

import Foundation
import Combine
import CoreLocation

@MainActor
final class CCForecastViewModel: ObservableObject {
    @Published var m_dailyForecasts: [CCDailyForecast] = []
    @Published var m_backgroundType: CCWeatherBackgroundType = .unknown
    @Published var m_isNight: Bool = false
    @Published var m_cityName: String = ""

    private let m_locationManager: CCLocationManager
    private let m_service: CCWeatherServiceProtocol
    private var m_cancellables = Set<AnyCancellable>()

    init(locationManager: CCLocationManager = CCLocationManager(), service: CCWeatherServiceProtocol = CCWeatherService()) {
        self.m_locationManager = locationManager
        self.m_service = service

        m_locationManager.$m_lastLocation
            .compactMap { $0 }
            .sink { [weak self] coord in
                Task { await self?.loadForecast(for: coord) }
            }
            .store(in: &m_cancellables)

        // DEVLOPMENT:  Simulator and no location is provided, fallback after a short delay for testing.
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let self = self else { return }
            if self.m_lastLocationIsEmpty() {
                // Example fallback: coordinates for London
                let fallback = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
                Task { await self.loadForecast(for: fallback) }
            }
        }
#endif
    }

    private func m_lastLocationIsEmpty() -> Bool {
        return m_locationManager.m_lastLocation == nil
    }

    func requestLocation() {
        m_locationManager.requestLocation()
    }

    func loadForecast(for coord: CLLocationCoordinate2D) async {
        do {
            let response = try await m_service.fetch5DayForecast(for: coord)
            m_cityName = response.city.name
            let daily = Self.groupDaily(from: response)
            m_dailyForecasts = daily
            m_backgroundType = Self.backgroundType(for: daily.first)
            // compute day/night using city's sunrise/sunset if available
            if let sunrise = response.city.sunrise, let sunset = response.city.sunset {
                // response times are in UTC seconds; timezone offset in seconds
                let tz = TimeInterval(response.city.timezone ?? 0)
                let nowUTC = Date().timeIntervalSince1970
                let localNow = nowUTC + tz
                m_isNight = !(localNow >= (sunrise + tz) && localNow < (sunset + tz))
            } else {
                let hour = Calendar.current.component(.hour, from: Date())
                m_isNight = !(6...18).contains(hour)
            }
        } catch {
            // forecasts on failure and log error for debugging.
            m_dailyForecasts = []
            m_backgroundType = .unknown
            m_cityName = ""
            print("Failed to load forecast for coord (\\(coord.latitude), \\(coord.longitude)): \\(error)")
        }
    }

    static func groupDaily(from response: CCMultiDayForecastResponse) -> [CCDailyForecast] {
        //Calender
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: response.list) { item in
            calendar.startOfDay(for: Date(timeIntervalSince1970: item.dt))
        }

        let mapped: [CCDailyForecast] = grouped.map { (day, items) in
            // pick the forecast item closest to midday
            let midday = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
            let chosen = items.min(by: { abs($0.dt - midday.timeIntervalSince1970) < abs($1.dt - midday.timeIntervalSince1970) }) ?? items.first!
            return CCDailyForecast(date: Date(timeIntervalSince1970: chosen.dt), temperatureC: Int(round(chosen.main.temp)), weatherMain: chosen.weather.first?.main ?? "", weatherId: chosen.weather.first?.id ?? 0)
        }

        return mapped.sorted(by: { $0.date < $1.date })
    }

    static func backgroundType(for day: CCDailyForecast?) -> CCWeatherBackgroundType {
        guard let day = day else { return .unknown }
        let main = day.weatherMain.lowercased()
        if main.contains("rain") || main.contains("drizzle") { return .rainy }
        if main.contains("cloud") || main.contains("overcast") { return .cloudy }
        if main.contains("sun") || main.contains("clear") { return .sunny }
        return .unknown
    }
}
