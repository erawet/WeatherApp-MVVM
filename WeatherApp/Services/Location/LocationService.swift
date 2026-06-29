//
//  LocationService.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Handles location permission and current coordinate lookup.
//

import CoreLocation
import Foundation

struct LocationCoordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

@MainActor
protocol LocationService {
    func requestCurrentLocation() async throws -> LocationCoordinate
}

@MainActor
final class CoreLocationService: NSObject, LocationService {
    private let locationManager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<LocationCoordinate, Error>?

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func requestCurrentLocation() async throws -> LocationCoordinate {
        guard CLLocationManager.locationServicesEnabled() else {
            throw WeatherAppError.locationUnavailable
        }

        let status = await authorizedStatus()

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw WeatherAppError.locationPermissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            guard locationContinuation == nil else {
                continuation.resume(throwing: WeatherAppError.locationUnavailable)
                return
            }

            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func authorizedStatus() async -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus

        guard status == .notDetermined else {
            return status
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        guard status != .notDetermined else {
            return
        }

        authorizationContinuation?.resume(returning: status)
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationContinuation?.resume(throwing: WeatherAppError.locationUnavailable)
            locationContinuation = nil
            return
        }

        let coordinate = LocationCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let coreLocationError = error as? CLError, coreLocationError.code == .denied {
            locationContinuation?.resume(throwing: WeatherAppError.locationPermissionDenied)
        } else {
            locationContinuation?.resume(throwing: WeatherAppError.locationUnavailable)
        }

        locationContinuation = nil
    }
}

struct UnavailableLocationService: LocationService {
    func requestCurrentLocation() async throws -> LocationCoordinate {
        throw WeatherAppError.locationUnavailable
    }
}
