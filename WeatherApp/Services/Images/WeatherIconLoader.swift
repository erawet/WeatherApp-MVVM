//
//  WeatherIconLoader.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Downloads and caches OpenWeather icon images.
//

import Foundation
import UIKit

protocol WeatherIconLoader {
    func icon(named iconName: String) async throws -> UIImage
}

final class OpenWeatherIconLoader: WeatherIconLoader {
    private let imageCache: ImageCache
    private let baseURL: String
    private let urlSession: URLSession

    init(
        imageCache: ImageCache,
        baseURL: String = AppConfiguration.openWeatherIconBaseURL,
        urlSession: URLSession = .shared
    ) {
        self.imageCache = imageCache
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    func icon(named iconName: String) async throws -> UIImage {
        let cacheKey = iconName

        if let cachedImage = imageCache.image(forKey: cacheKey) {
            return cachedImage
        }

        guard let url = URL(string: "\(baseURL)/\(iconName)@2x.png") else {
            throw WeatherAppError.invalidURL
        }

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAppError.invalidResponse
        }

        guard let image = UIImage(data: data) else {
            throw WeatherAppError.decodingFailed
        }

        imageCache.saveImage(image, forKey: cacheKey)
        return image
    }
}

struct UnavailableWeatherIconLoader: WeatherIconLoader {
    func icon(named iconName: String) async throws -> UIImage {
        throw WeatherAppError.invalidResponse
    }
}
