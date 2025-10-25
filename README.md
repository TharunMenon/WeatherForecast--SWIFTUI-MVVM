# WeatherForecast--SWIFTUI-MVVM
SwiftUI iOS app showing a 5-day weather forecast using OpenWeatherMap API. Built with MVVM, Combine, and CoreLocation.

Features

Location-based Forecasts — Automatically fetches the user’s current location.

5-Day Forecast View — Displays temperature, weather icons, and conditions for the next 5 days.

Modern SwiftUI UI — Built with adaptive layouts, gradients, and rounded cards.

MVVM Architecture — Clean separation between business logic and UI.

Unit Tests Included — Comprehensive test coverage with mock services.

Continuous Integration (CI) — GitHub Actions workflow for linting and testing.


Setup
- Add your OpenWeatherMap API key to the app's `AppInfo.plist` with the key `OPENWEATHER_API_KEY`.
  - This repository already contains an `AppInfo.plist` at `WeatherForecast/AppInfo.plist` with a placeholder API key (for testing). For production, remove hard-coded keys and use a secure secret store or CI secrets.
- Add location usage descriptions to `AppInfo.plist`:
  - `NSLocationWhenInUseUsageDescription` with a user-facing reason.

Running locally
- Open `WeatherForecast.xcodeproj` in Xcode, select a simulator (iPhone 16 recommended), and run.

Tests
- Unit tests are in the `WeatherForecastTests` target. Run them in Xcode or via `xcodebuild test`.

CI
- A GitHub Actions workflow is added at `.github/workflows/ci.yml` which runs SwiftLint and the test suite on macOS runners.
