//
//  APIClient.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Low-level networking abstraction.
//

import Foundation

protocol APIClient {
    func request<Response: Decodable>(_ url: URL) async throws -> Response
}

final class URLSessionAPIClient: APIClient {
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    init(urlSession: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func request<Response: Decodable>(_ url: URL) async throws -> Response {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(from: url)
        } catch {
            throw WeatherAppError.unknown
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAppError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAppError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw WeatherAppError.decodingFailed
        }
    }
}
