//
//  CityCoordinate.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Domain model for a resolved city location.
//

struct CityCoordinate: Equatable {
    let cityName: String
    let state: String?
    let countryCode: String
    let latitude: Double
    let longitude: Double
}
