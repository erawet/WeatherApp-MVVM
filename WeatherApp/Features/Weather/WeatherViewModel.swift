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
import UIKit

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var searchText: String
    @Published private(set) var isLoading = false
    @Published private(set) var weather: Weather?
    @Published private(set) var weatherIconImage: UIImage?
    @Published private(set) var errorMessage: String?

    private let weatherRepository: WeatherRepository
    private let lastSearchStore: LastSearchStore
    private let locationService: LocationService
    private let weatherIconLoader: WeatherIconLoader
    private var hasLoadedInitialWeather = false
    private var hasLoadedLastSearchedCity = false

    init(
        weatherRepository: WeatherRepository,
        lastSearchStore: LastSearchStore,
        locationService: LocationService,
        weatherIconLoader: WeatherIconLoader,
        initialSearchText: String = ""
    ) {
        self.weatherRepository = weatherRepository
        self.lastSearchStore = lastSearchStore
        self.locationService = locationService
        self.weatherIconLoader = weatherIconLoader
        self.searchText = initialSearchText
    }

    func loadInitialWeather() async {
        guard hasLoadedInitialWeather == false else {
            return
        }

        hasLoadedInitialWeather = true

        // Prefer current-location weather on launch; fall back to the last searched city when location is unavailable.
        if await loadWeatherForCurrentLocationIfAllowed() {
            return
        }

        await loadLastSearchedCityIfAvailable()
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
            await applyFetchedWeather(fetchedWeather)
        } catch {
            weather = nil
            weatherIconImage = nil
            errorMessage = message(for: error)
        }

        isLoading = false
    }

    func clearError() {
        errorMessage = nil
    }

    private func loadWeatherForCurrentLocationIfAllowed() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let coordinate = try await locationService.requestCurrentLocation()
            let fetchedWeather = try await weatherRepository.weather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            await applyFetchedWeather(fetchedWeather)
            isLoading = false
            return true
        } catch WeatherAppError.locationPermissionDenied, WeatherAppError.locationUnavailable {
            isLoading = false
            return false
        } catch {
            weather = nil
            weatherIconImage = nil
            errorMessage = message(for: error)
            isLoading = false
            return true
        }
    }

    private func applyFetchedWeather(_ fetchedWeather: Weather) async {
        weather = fetchedWeather
        weatherIconImage = nil
        searchText = fetchedWeather.cityName
        lastSearchStore.saveLastSearchedCity(fetchedWeather.cityName)
        weatherIconImage = try? await weatherIconLoader.icon(named: fetchedWeather.condition.iconName)
    }

    private func message(for error: Error) -> String {
        guard let weatherAppError = error as? WeatherAppError else {
            return WeatherAppError.unknown.userMessage
        }

        return weatherAppError.userMessage
    }
}
