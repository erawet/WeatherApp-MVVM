# WeatherApp

WeatherApp is a native iOS weather application with a SwiftUI user interface that lets users search for current weather by US city or load weather for their current location. It uses OpenWeather data, displays current conditions with weather icons, remembers the last successful search, and keeps the code organized around testable app layers.

## Features

- Search current weather by city name
- SwiftUI weather search and summary screen
- Request location permission and load weather by coordinates when allowed
- Fall back to the last searched city when location is unavailable
- Persist the last successful city search with `UserDefaults`
- Download and cache OpenWeather condition icons
- Display temperature, feels-like temperature, high, low, humidity, wind speed, and condition summary
- Show loading and error states with user-friendly messages
- Unit tests for model mapping and ViewModel behavior

## Architecture

The app uses an MVVM-C style structure:

- **Model**: Domain types such as `Weather`, `WeatherCondition`, and `CityCoordinate`
- **View**: SwiftUI screens for the weather search and summary UI
- **ViewModel**: Presentation logic, loading state, validation, persistence, location fallback, and icon loading
- **Coordinator**: UIKit app flow setup through `AppCoordinator`
- **Dependency Injection**: `DependencyContainer` creates and injects concrete services
- **Services**: Networking, geocoding, weather lookup, location, persistence, and image caching

UIKit is used for application coordination and hosting, while SwiftUI is used for the weather screen UI. This keeps the app flow explicit while keeping the feature UI lightweight and reactive.

## Project Structure

```text
WeatherApp/
  App/
    AppCoordinator.swift
    DependencyContainer.swift
    SceneDelegate.swift
  Features/
    Weather/
      WeatherView.swift
      WeatherViewController.swift
      WeatherViewModel.swift
  Models/
    CityCoordinate.swift
    Weather.swift
    WeatherCondition.swift
  Services/
    API/
    Images/
    Location/
    Persistence/
  Utilities/
    APIKeys.swift
    AppConfiguration.swift
    WeatherAppError.swift

WeatherAppTests/
  WeatherAppTests.swift
```

## API Key Setup

WeatherApp uses the OpenWeather API. Add your API key in:

```text
WeatherApp/Utilities/APIKeys.swift
```

Replace the placeholder value:

```swift
enum APIKeys {
    static let openWeather = "YOUR_OPENWEATHER_API_KEY"
}
```

Keep this key private. Do not commit a real API key to source control.

## OpenWeather Usage

The app uses:

- OpenWeather Geocoding API to convert city names to coordinates
- OpenWeather Current Weather API to fetch weather by latitude and longitude
- OpenWeather icon URLs for condition icons

Weather requests are made by coordinates instead of deprecated city-name weather requests.

## Running the App

1. Open `WeatherApp.xcodeproj` in Xcode.
2. Add your OpenWeather API key in `APIKeys.swift`.
3. Select the `WeatherApp` scheme.
4. Run on a simulator or device.

For location testing in Simulator, set a simulated location from Xcode or Simulator before launching the app.

## Tests

Run unit tests from Xcode with the `WeatherApp` scheme, or use:

```bash
xcodebuild test -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17'
```

The unit tests cover:

- API response DTO mapping into domain models
- Invalid weather response handling
- City search ViewModel behavior
- Empty search validation
- Last searched city fallback
- Location-based weather loading

## Requirements

- Xcode
- iOS Simulator or iOS device
- OpenWeather API key
- No third-party dependencies
