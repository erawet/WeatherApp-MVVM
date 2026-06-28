//
//  GeocodingAPIService.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Resolves city input into latitude and longitude.
//

import Foundation

protocol GeocodingAPIService {
    func coordinate(forCity city: String) async throws -> CityCoordinate
}

final class OpenWeatherGeocodingAPIService: GeocodingAPIService {
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

    func coordinate(forCity city: String) async throws -> CityCoordinate {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCity.isEmpty == false else {
            throw WeatherAppError.cityNotFound
        }

        var components = URLComponents(string: "\(baseURL)/geo/1.0/direct")
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(trimmedCity),US"),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw WeatherAppError.invalidURL
        }

        let response: [GeocodingResponseDTO] = try await apiClient.request(url)
        guard let firstResult = response.first else {
            throw WeatherAppError.cityNotFound
        }

        return firstResult.toDomain()
    }
}
