import Foundation

//  WeatherForecast
//  Created by Tharun Menon on 24/10/25.

// API models - mirror only needed fields from OpenWeatherMap 5 day forecast
struct CCMultiDayForecastResponse: Codable {
    let list: [CCForecastItem]
    let city: CCCity
}

struct CCForecastItem: Codable {
    let dt: TimeInterval
    let main: CCMain
    let weather: [CCWeather]
}

struct CCMain: Codable {
    let temp: Double
}

struct CCWeather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct CCCity: Codable {
    let name: String
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
    let timezone: Int?
}

// View model friendly daily forecast
struct CCDailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let temperatureC: Int
    let weatherMain: String
    let weatherId: Int
}

enum CCWeatherBackgroundType {
    case sunny, cloudy, rainy, unknown
}
