//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Creates the app window and starts the coordinator.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        let dependencies = DependencyContainer()
        let coordinator = AppCoordinator(window: window, dependencies: dependencies)

        self.window = window
        appCoordinator = coordinator
        coordinator.start()
    }
}
