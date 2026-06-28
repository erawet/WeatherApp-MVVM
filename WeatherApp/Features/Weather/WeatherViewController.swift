//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  UIKit container that will host the SwiftUI WeatherView.
//

import SwiftUI
import UIKit

final class WeatherViewController: UIViewController {
    private let viewModel: WeatherViewModel
    private var hostingController: UIHostingController<WeatherView>?

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("WeatherViewController does not support storyboard initialization.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Weather"
        view.backgroundColor = .systemBackground
        embedWeatherView()
    }

    private func embedWeatherView() {
        let hostingController = UIHostingController(rootView: WeatherView(viewModel: viewModel))

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
}
