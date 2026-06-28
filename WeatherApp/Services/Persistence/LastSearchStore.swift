//
//  LastSearchStore.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Persists and restores the last successful city search.
//

import Foundation

protocol LastSearchStore {
    func loadLastSearchedCity() -> String?
    func saveLastSearchedCity(_ city: String)
}

final class UserDefaultsLastSearchStore: LastSearchStore {
    private enum Keys {
        static let lastSearchedCity = "lastSearchedCity"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadLastSearchedCity() -> String? {
        let city = userDefaults.string(forKey: Keys.lastSearchedCity)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let city, city.isEmpty == false else {
            return nil
        }

        return city
    }

    func saveLastSearchedCity(_ city: String) {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedCity.isEmpty == false else {
            return
        }

        userDefaults.set(trimmedCity, forKey: Keys.lastSearchedCity)
    }
}

struct EmptyLastSearchStore: LastSearchStore {
    func loadLastSearchedCity() -> String? {
        nil
    }

    func saveLastSearchedCity(_ city: String) {
    }
}
