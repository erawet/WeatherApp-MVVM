//
//  WeatherAPIService.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Fetches weather data for coordinates.
//

import Foundation

protocol WeatherAPIService {
    func weather(latitude: Double, longitude: Double) async throws -> Weather
}

final class OpenWeatherAPIService: WeatherAPIService {
    private let apiClient: APIClient
    private let apiKey: String
    private let baseURL: String

    init(
        apiClient: APIClient,
        apiKey: String,
        baseURL: String = AppConfiguration.openWeatherBaseURL
    ) {
        self.apiClient = apiClient
        self.apiKey = apiKey
        self.baseURL = baseURL
    }

    func weather(latitude: Double, longitude: Double) async throws -> Weather {
        var components = URLComponents(string: "\(baseURL)/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw WeatherAppError.invalidURL
        }

        let response: WeatherResponseDTO = try await apiClient.request(url)
        return try response.toDomain()
    }
}
