//
//  WeatherCondition.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Domain model for weather summary and icon metadata.
//

struct WeatherCondition: Equatable {
    let title: String
    let description: String
    let iconName: String
}
