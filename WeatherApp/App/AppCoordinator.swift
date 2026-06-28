//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Coordinates app startup and navigation.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let dependencies: DependencyContainer

    init(window: UIWindow, dependencies: DependencyContainer) {
        self.window = window
        self.dependencies = dependencies
    }

    func start() {
        // Later: build the Weather screen and set it as the root view controller.
    }
}
