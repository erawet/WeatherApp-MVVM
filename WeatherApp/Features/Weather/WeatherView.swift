//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  SwiftUI view for the weather search experience.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        Text("Weather")
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel(weatherRepository: MissingAPIKeyWeatherRepository()))
}
