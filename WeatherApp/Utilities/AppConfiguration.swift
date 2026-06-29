//
//  AppConfiguration.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Central location for app configuration values.
//

import Foundation

enum AppConfiguration {
    static let openWeatherBaseURL = "https://api.openweathermap.org"
    static let openWeatherIconBaseURL = "https://openweathermap.org/img/wn"

    static var openWeatherAPIKey: String? {
        let apiKey = APIKeys.openWeather.trimmingCharacters(in: .whitespacesAndNewlines)

        guard apiKey.isEmpty == false, apiKey != "YOUR_OPENWEATHER_API_KEY" else {
            return nil
        }

        return apiKey
    }
}
