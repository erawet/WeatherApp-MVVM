//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Combines geocoding and weather calls for the ViewModel.
//

protocol WeatherRepository {
    func weather(forCity city: String) async throws -> Weather
    func weather(latitude: Double, longitude: Double) async throws -> Weather
}

final class OpenWeatherRepository: WeatherRepository {
    private let geocodingService: GeocodingAPIService
    private let weatherService: WeatherAPIService

    init(geocodingService: GeocodingAPIService, weatherService: WeatherAPIService) {
        self.geocodingService = geocodingService
        self.weatherService = weatherService
    }

    func weather(forCity city: String) async throws -> Weather {
        let coordinate = try await geocodingService.coordinate(forCity: city)
        return try await weather(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func weather(latitude: Double, longitude: Double) async throws -> Weather {
        try await weatherService.weather(latitude: latitude, longitude: longitude)
    }
}

struct MissingAPIKeyWeatherRepository: WeatherRepository {
    func weather(forCity city: String) async throws -> Weather {
        throw WeatherAppError.missingAPIKey
    }

    func weather(latitude: Double, longitude: Double) async throws -> Weather {
        throw WeatherAppError.missingAPIKey
    }
}
