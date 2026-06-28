//
//  Weather.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Domain model for current weather information shown in the app.
//

struct Weather: Equatable {
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let minimumTemperature: Double
    let maximumTemperature: Double
    let humidity: Int
    let windSpeed: Double
    let condition: WeatherCondition
}
