//
//  WeatherAppError.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  App-specific errors that can be mapped to user-friendly messages.
//

enum WeatherAppError: Error, Equatable {
    case invalidURL
    case missingAPIKey
    case cityNotFound
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed
    case unknown
}

extension WeatherAppError {
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Something went wrong while preparing the weather request."
        case .missingAPIKey:
            return "The weather service is not configured yet. Please add an API key."
        case .cityNotFound:
            return "We could not find that city. Please check the spelling and try again."
        case .invalidResponse:
            return "The weather service returned an unexpected response."
        case .serverError:
            return "The weather service is unavailable right now. Please try again later."
        case .decodingFailed:
            return "We could not read the weather data returned by the service."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
