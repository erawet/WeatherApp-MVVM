//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Don Wettasinghe on 6/27/26.
//

import UIKit
import XCTest
@testable import WeatherApp

@MainActor
final class WeatherAppTests: XCTestCase {
    func testWeatherResponseMapsToDomainModel() throws {
        let json = """
        {
            "name": "Austin",
            "weather": [
                {
                    "main": "Clouds",
                    "description": "few clouds",
                    "icon": "02d"
                }
            ],
            "main": {
                "temp": 88.4,
                "feels_like": 91.0,
                "temp_min": 84.2,
                "temp_max": 92.7,
                "humidity": 55
            },
            "wind": {
                "speed": 8.3
            }
        }
        """

        let response = try JSONDecoder().decode(WeatherResponseDTO.self, from: Data(json.utf8))
        let weather = try response.toDomain()

        XCTAssertEqual(weather.cityName, "Austin")
        XCTAssertEqual(weather.temperature, 88.4)
        XCTAssertEqual(weather.feelsLike, 91.0)
        XCTAssertEqual(weather.minimumTemperature, 84.2)
        XCTAssertEqual(weather.maximumTemperature, 92.7)
        XCTAssertEqual(weather.humidity, 55)
        XCTAssertEqual(weather.windSpeed, 8.3)
        XCTAssertEqual(weather.condition.title, "Clouds")
        XCTAssertEqual(weather.condition.description, "few clouds")
        XCTAssertEqual(weather.condition.iconName, "02d")
    }

    func testWeatherResponseWithoutConditionThrowsDecodingFailed() throws {
        let response = WeatherResponseDTO(
            name: "Austin",
            weather: [],
            main: MainWeatherDTO(
                temp: 88,
                feelsLike: 90,
                tempMin: 80,
                tempMax: 92,
                humidity: 50
            ),
            wind: WindDTO(speed: 7)
        )

        XCTAssertThrowsError(try response.toDomain()) { error in
            XCTAssertEqual(error as? WeatherAppError, .decodingFailed)
        }
    }

    func testSearchLoadsWeatherAndIconForCity() async {
        let expectedWeather = Weather.testWeather(cityName: "Chicago", iconName: "03d")
        let expectedIcon = UIImage.testImage()
        let repository = FakeWeatherRepository(cityWeather: expectedWeather)
        let store = FakeLastSearchStore()
        let iconLoader = FakeWeatherIconLoader(image: expectedIcon)
        let viewModel = WeatherViewModel(
            weatherRepository: repository,
            lastSearchStore: store,
            locationService: FakeLocationService(result: .failure(WeatherAppError.locationUnavailable)),
            weatherIconLoader: iconLoader,
            initialSearchText: "  chicago  "
        )

        await viewModel.search()

        XCTAssertEqual(repository.searchedCity, "chicago")
        XCTAssertEqual(viewModel.weather, expectedWeather)
        XCTAssertEqual(viewModel.searchText, "Chicago")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(store.savedCity, "Chicago")
        XCTAssertEqual(iconLoader.requestedIconName, "03d")
        XCTAssertIdentical(viewModel.weatherIconImage, expectedIcon)
    }

    func testSearchWithEmptyCityShowsValidationMessage() async {
        let repository = FakeWeatherRepository(cityWeather: .testWeather())
        let viewModel = WeatherViewModel(
            weatherRepository: repository,
            lastSearchStore: FakeLastSearchStore(),
            locationService: FakeLocationService(result: .failure(WeatherAppError.locationUnavailable)),
            weatherIconLoader: FakeWeatherIconLoader(),
            initialSearchText: "   "
        )

        await viewModel.search()

        XCTAssertNil(repository.searchedCity)
        XCTAssertNil(viewModel.weather)
        XCTAssertEqual(viewModel.errorMessage, "Please enter a city name.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadInitialWeatherFallsBackToLastSavedCityWhenLocationUnavailable() async {
        let expectedWeather = Weather.testWeather(cityName: "Boston", iconName: "01n")
        let repository = FakeWeatherRepository(cityWeather: expectedWeather)
        let store = FakeLastSearchStore(lastCity: "Boston")
        let viewModel = WeatherViewModel(
            weatherRepository: repository,
            lastSearchStore: store,
            locationService: FakeLocationService(result: .failure(WeatherAppError.locationUnavailable)),
            weatherIconLoader: FakeWeatherIconLoader()
        )

        await viewModel.loadInitialWeather()

        XCTAssertEqual(repository.searchedCity, "Boston")
        XCTAssertNil(repository.requestedLatitude)
        XCTAssertEqual(viewModel.weather, expectedWeather)
        XCTAssertEqual(viewModel.searchText, "Boston")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadInitialWeatherUsesLocationCoordinatesWhenAllowed() async {
        let expectedWeather = Weather.testWeather(cityName: "Current Location")
        let repository = FakeWeatherRepository(coordinateWeather: expectedWeather)
        let coordinate = LocationCoordinate(latitude: 41.8781, longitude: -87.6298)
        let viewModel = WeatherViewModel(
            weatherRepository: repository,
            lastSearchStore: FakeLastSearchStore(lastCity: "Boston"),
            locationService: FakeLocationService(result: .success(coordinate)),
            weatherIconLoader: FakeWeatherIconLoader()
        )

        await viewModel.loadInitialWeather()

        XCTAssertNil(repository.searchedCity)
        XCTAssertEqual(repository.requestedLatitude, coordinate.latitude)
        XCTAssertEqual(repository.requestedLongitude, coordinate.longitude)
        XCTAssertEqual(viewModel.weather, expectedWeather)
        XCTAssertEqual(viewModel.searchText, "Current Location")
        XCTAssertFalse(viewModel.isLoading)
    }
}

private final class FakeWeatherRepository: WeatherRepository {
    private let cityWeather: Weather
    private let coordinateWeather: Weather
    private let error: Error?

    private(set) var searchedCity: String?
    private(set) var requestedLatitude: Double?
    private(set) var requestedLongitude: Double?

    init(
        cityWeather: Weather = .testWeather(),
        coordinateWeather: Weather = .testWeather(),
        error: Error? = nil
    ) {
        self.cityWeather = cityWeather
        self.coordinateWeather = coordinateWeather
        self.error = error
    }

    func weather(forCity city: String) async throws -> Weather {
        searchedCity = city

        if let error {
            throw error
        }

        return cityWeather
    }

    func weather(latitude: Double, longitude: Double) async throws -> Weather {
        requestedLatitude = latitude
        requestedLongitude = longitude

        if let error {
            throw error
        }

        return coordinateWeather
    }
}

private final class FakeLastSearchStore: LastSearchStore {
    private let lastCity: String?
    private(set) var savedCity: String?

    init(lastCity: String? = nil) {
        self.lastCity = lastCity
    }

    func loadLastSearchedCity() -> String? {
        lastCity
    }

    func saveLastSearchedCity(_ city: String) {
        savedCity = city
    }
}

private struct FakeLocationService: LocationService {
    let result: Result<LocationCoordinate, Error>

    func requestCurrentLocation() async throws -> LocationCoordinate {
        try result.get()
    }
}

private final class FakeWeatherIconLoader: WeatherIconLoader {
    private let image: UIImage
    private(set) var requestedIconName: String?

    init(image: UIImage = UIImage.testImage()) {
        self.image = image
    }

    func icon(named iconName: String) async throws -> UIImage {
        requestedIconName = iconName
        return image
    }
}

private extension Weather {
    static func testWeather(
        cityName: String = "Austin",
        iconName: String = "01d"
    ) -> Weather {
        Weather(
            cityName: cityName,
            temperature: 72,
            feelsLike: 74,
            minimumTemperature: 68,
            maximumTemperature: 80,
            humidity: 40,
            windSpeed: 6,
            condition: WeatherCondition(
                title: "Clear",
                description: "clear sky",
                iconName: iconName
            )
        )
    }
}

private extension UIImage {
    static func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
}
