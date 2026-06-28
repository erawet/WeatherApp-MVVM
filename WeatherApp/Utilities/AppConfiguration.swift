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
        guard
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String,
            apiKey.isEmpty == false
        else {
            return nil
        }

        return apiKey
    }
}
