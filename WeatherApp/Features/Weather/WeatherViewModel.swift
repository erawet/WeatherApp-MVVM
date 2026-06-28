//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Presentation logic for searching and displaying weather.
//

import Combine
import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var searchText: String
    @Published private(set) var isLoading = false
    @Published private(set) var weather: Weather?
    @Published private(set) var errorMessage: String?

    private let weatherRepository: WeatherRepository
    private let lastSearchStore: LastSearchStore
    private var hasLoadedLastSearchedCity = false

    init(
        weatherRepository: WeatherRepository,
        lastSearchStore: LastSearchStore,
        initialSearchText: String = ""
    ) {
        self.weatherRepository = weatherRepository
        self.lastSearchStore = lastSearchStore
        self.searchText = initialSearchText
    }

    func loadLastSearchedCityIfAvailable() async {
        guard hasLoadedLastSearchedCity == false else {
            return
        }

        hasLoadedLastSearchedCity = true

        guard let city = lastSearchStore.loadLastSearchedCity() else {
            return
        }

        searchText = city
        await search()
    }

    func search() async {
        let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard city.isEmpty == false else {
            weather = nil
            errorMessage = "Please enter a city name."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let fetchedWeather = try await weatherRepository.weather(forCity: city)
            weather = fetchedWeather
            searchText = fetchedWeather.cityName
            lastSearchStore.saveLastSearchedCity(fetchedWeather.cityName)
        } catch {
            weather = nil
            errorMessage = message(for: error)
        }

        isLoading = false
    }

    func clearError() {
        errorMessage = nil
    }

    private func message(for error: Error) -> String {
        guard let weatherAppError = error as? WeatherAppError else {
            return WeatherAppError.unknown.userMessage
        }

        return weatherAppError.userMessage
    }
}
