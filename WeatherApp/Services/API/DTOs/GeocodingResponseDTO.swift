//
//  GeocodingResponseDTO.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Response model for OpenWeather's direct geocoding endpoint.
//

struct GeocodingResponseDTO: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    func toDomain() -> CityCoordinate {
        CityCoordinate(
            cityName: name,
            state: state,
            countryCode: country,
            latitude: lat,
            longitude: lon
        )
    }
}
