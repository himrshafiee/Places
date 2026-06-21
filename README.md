# Places

An iOS app that lists locations and deep-links into a (modified) Wikipedia app's Places tab so the user can explore each one. Users can also enter custom coordinates and open them the same way.

## Demo

<img src="demo.gif" width="400" alt="demo">


## Features

- Fetches a list of locations from a remote JSON endpoint.
- Taps on a row to open the location in the Wikipedia app via the `wikipedia://places?lat=…&lon=…&name=…` deep link.
- "Add custom location" screen with live coordinate validation (WGS84 ranges, `.` or `,` decimal separator) and an optional name.
- Friendly fallback when the Wikipedia app isn't installed.

## Getting started

```sh
open Places.xcodeproj
```

To test the Wikipedia deep link end-to-end, install the modified Wikipedia app that registers the `wikipedia://places` URL scheme on the same simulator/device.

## Project structure

```
Places/
├── Places/                       # App target
│   ├── Domain/                   # Models, use cases, routers, CoordinateParser
│   ├── Data/                     # Network repositories + response validators
│   ├── Presentation/             # SwiftUI views + @Observable view models
│   │   ├── LocationsList/
│   │   ├── AddCustomLocation/
│   │   └── Splash/
│   ├── DependencyInjection/      # AppContainer + per-layer containers
│   ├── Extensions/               # String localization helpers
│   └── Resources/                # Localizable.strings, assets
├── Modules/
│   └── Networking/               # Local SwiftPM package: RequestManager, parsers, validators, plugins
└── PlacesTests/                  # Unit tests (Swift Testing)
```

### Architecture

```
View  ─▶  ViewModel  ─▶  UseCase  ─▶  Repository  ─▶  Networking
```

- **Domain** owns models, use case protocols, and pure helpers (e.g. `CoordinateParser`).
- **Data** implements the repository protocols on top of the `Networking` package.
- **Presentation** uses `@Observable` view models (`@MainActor`-isolated) and SwiftUI views.
- **DependencyInjection** wires everything through a small container hierarchy (`AppContainer` → network → repositories → use cases → view models). Views resolve dependencies through `AppContainer.shared`.

### Networking module

The reusable `Networking` Swift package provides:

- `RequestManager` coordinating `URLRequestBuilder`, an `HTTPDataLoading` transport, response validators, parsers, and plugins.
- Pluggable parsers (`DecodableParser`, `RawDataParser`) and validators (status code, non-empty body).
- A `NetworkLogger` plugin and a `StubHTTPDataLoader` for tests.

## Testing

The project uses [Swift Testing](https://developer.apple.com/documentation/testing).

- `PlacesTests/` — unit tests for Repositories, UseCases, ViewModels, and the `CoordinateParser`.
- `PlacesTests/Mocks/` — shared test doubles for UseCases and `URLOpening`.

Run all tests from Xcode (⌘U) or from the command line:

```sh
xcodebuild \
  -project Places.xcodeproj \
  -scheme Places \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```
