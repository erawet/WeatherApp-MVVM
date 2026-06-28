//
//  WeatherResponseDTO.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Response model for OpenWeather's current weather endpoint.
//

struct WeatherResponseDTO: Decodable {
    let name: String
    let weather: [WeatherConditionDTO]
    let main: MainWeatherDTO
    let wind: WindDTO

    func toDomain() throws -> Weather {
        guard let firstCondition = weather.first else {
            throw WeatherAppError.decodingFailed
        }

        return Weather(
            cityName: name,
            temperature: main.temp,
            feelsLike: main.feelsLike,
            minimumTemperature: main.tempMin,
            maximumTemperature: main.tempMax,
            humidity: main.humidity,
            windSpeed: wind.speed,
            condition: firstCondition.toDomain()
        )
    }
}

struct WeatherConditionDTO: Decodable {
    let main: String
    let description: String
    let icon: String

    func toDomain() -> WeatherCondition {
        WeatherCondition(
            title: main,
            description: description,
            iconName: icon
        )
    }
}

struct MainWeatherDTO: Decodable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int

    private enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }
}

struct WindDTO: Decodable {
    let speed: Double
}
