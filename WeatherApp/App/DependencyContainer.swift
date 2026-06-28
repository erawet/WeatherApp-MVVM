//
//  DependencyContainer.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Owns concrete app dependencies and injects them where needed.
//

struct DependencyContainer {
    func makeWeatherViewModel() -> WeatherViewModel {
        WeatherViewModel(
            weatherRepository: makeWeatherRepository(),
            lastSearchStore: makeLastSearchStore()
        )
    }

    private func makeWeatherRepository() -> WeatherRepository {
        guard let apiKey = AppConfiguration.openWeatherAPIKey else {
            return MissingAPIKeyWeatherRepository()
        }

        let apiClient = URLSessionAPIClient()
        let geocodingService = OpenWeatherGeocodingAPIService(
            apiClient: apiClient,
            apiKey: apiKey
        )
        let weatherService = OpenWeatherAPIService(
            apiClient: apiClient,
            apiKey: apiKey
        )

        return OpenWeatherRepository(
            geocodingService: geocodingService,
            weatherService: weatherService
        )
    }

    private func makeLastSearchStore() -> LastSearchStore {
        UserDefaultsLastSearchStore()
    }
}
