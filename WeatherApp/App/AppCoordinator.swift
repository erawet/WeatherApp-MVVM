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
        let viewModel = dependencies.makeWeatherViewModel()
        let weatherViewController = WeatherViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: weatherViewController)

        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
