
//  WeatherForecast
//  CCWeatherService
//  Created by Tharun Menon on 24/10/25.


import Foundation
import CoreLocation

protocol CCWeatherServiceProtocol {
    func fetch5DayForecast(for location: CLLocationCoordinate2D) async throws -> CCMultiDayForecastResponse
}

final class CCWeatherService: CCWeatherServiceProtocol {
    private let m_session: URLSession

    init(session: URLSession = .shared) {
        self.m_session = session
    }

    func fetch5DayForecast(for location: CLLocationCoordinate2D) async throws -> CCMultiDayForecastResponse {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String, !apiKey.isEmpty else {
            throw NSError(domain: "CCWeatherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing API Key (OPENWEATHER_API_KEY) in Info.plist"])
        }

        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lon", value: "\(location.longitude)"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        let (data, response) = try await m_session.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "CCWeatherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response from weather API"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(CCMultiDayForecastResponse.self, from: data)
    }
}

// Simple mock for unit tests
final class CCWeatherServiceMock: CCWeatherServiceProtocol {
    var m_response: CCMultiDayForecastResponse?
    var m_error: Error?

    func fetch5DayForecast(for location: CLLocationCoordinate2D) async throws -> CCMultiDayForecastResponse {
        if let err = m_error { throw err }
        if let resp = m_response { return resp }
        throw NSError(domain: "CCWeatherServiceMock", code: 0, userInfo: nil)
    }
}
