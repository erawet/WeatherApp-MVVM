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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                searchSection

                if viewModel.isLoading {
                    loadingView
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("weatherErrorMessage")
                }

                if let weather = viewModel.weather {
                    WeatherSummaryView(weather: weather)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadLastSearchedCityIfAvailable()
        }
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("City")
                .font(.headline)

            HStack(spacing: 12) {
                TextField("Enter a US city", text: $viewModel.searchText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("citySearchTextField")
                    .onSubmit {
                        search()
                    }

                Button {
                    search()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(width: 64)
                    } else {
                        Text("Search")
                            .frame(minWidth: 64)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("citySearchButton")
            }
        }
    }

    private var loadingView: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Loading weather...")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("weatherLoadingIndicator")
    }

    private func search() {
        Task {
            await viewModel.search()
        }
    }
}

private struct WeatherSummaryView: View {
    let weather: Weather

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(weather.cityName)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(weather.condition.description.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(temperatureText(weather.temperature))
                .font(.system(size: 56, weight: .semibold))
                .accessibilityLabel("Temperature \(temperatureText(weather.temperature))")

            VStack(spacing: 10) {
                WeatherDetailRow(title: "Feels Like", value: temperatureText(weather.feelsLike))
                WeatherDetailRow(title: "Low", value: temperatureText(weather.minimumTemperature))
                WeatherDetailRow(title: "High", value: temperatureText(weather.maximumTemperature))
                WeatherDetailRow(title: "Humidity", value: "\(weather.humidity)%")
                WeatherDetailRow(title: "Wind", value: "\(roundedText(weather.windSpeed)) mph")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("weatherSummary")
    }

    private func temperatureText(_ value: Double) -> String {
        "\(roundedText(value))°F"
    }

    private func roundedText(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }
}

private struct WeatherDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .font(.body)
    }
}

#Preview {
    WeatherView(
        viewModel: WeatherViewModel(
            weatherRepository: MissingAPIKeyWeatherRepository(),
            lastSearchStore: EmptyLastSearchStore()
        )
    )
}
