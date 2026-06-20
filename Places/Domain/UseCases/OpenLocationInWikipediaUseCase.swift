//
//  OpenLocationInWikipediaUseCase.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

// MARK: - URL opener indirection (testability)

@MainActor
protocol URLOpening: AnyObject {
    func canOpen(_ url: URL) -> Bool
    func open(_ url: URL) async -> Bool
}

// MARK: - Protocol
@MainActor
protocol OpenLocationInWikipediaUseCaseProtocol: Sendable {
   
    /// Open the supplied coordinate in the Wikipedia app's Places tab.
    /// - Returns: `true` if the system handed the URL to Wikipedia, `false` if
    ///   the Wikipedia app isn't installed (or `UIApplication.open` reported failure).
    /// - Throws: `OpenLocationInWikipediaError.invalidCoordinate` if lat/lon are out of range.
    func execute(location: Location) async throws -> Bool

    /// Whether the Wikipedia app appears to be installed. Used by views to
    /// show a friendly "install Wikipedia" hint instead of silently failing.
    func isWikipediaInstalled() -> Bool
}

enum OpenLocationInWikipediaError: Error, Equatable {
    case invalidCoordinate(latitude: Double, longitude: Double)
    case urlConstructionFailed
}

// MARK: - Implementation

@MainActor
final class OpenLocationInWikipediaUseCase: OpenLocationInWikipediaUseCaseProtocol {

    private let opener: URLOpening

    init(opener: URLOpening) {
        self.opener = opener
    }

    func execute(location: Location) async throws -> Bool {
        guard Self.isValid(latitude: location.latitude, longitude: location.longitude) else {
            throw OpenLocationInWikipediaError.invalidCoordinate(latitude: location.latitude, longitude: location.longitude)
        }

        guard let url = Self.makeWikipediaPlacesURL(latitude: location.latitude, longitude: location.longitude, name: location.name) else {
            throw OpenLocationInWikipediaError.urlConstructionFailed
        }

        // Even if canOpen returns false (Wikipedia not installed), still ask the system to open —
        // the OS will show the App Store. But return the opener's result so callers can react.
        return await opener.open(url)
    }

    func isWikipediaInstalled() -> Bool {
        guard let probe = URL(string: "wikipedia://places") else { return false }
        return opener.canOpen(probe)
    }

    // MARK: Helpers

    static func isValid(latitude: Double, longitude: Double) -> Bool {
        CoordinateParser.isValid(latitude: latitude, longitude: longitude)
    }

    /// Builds the deep link consumed by the modified Wikipedia app:
    /// `wikipedia://places?lat=<lat>&lon=<lon>[&name=<percent-encoded>]`.
    /// Exposed `static` so unit tests can assert the exact string.
    static func makeWikipediaPlacesURL(latitude: Double, longitude: Double, name: String?) -> URL? {
        var components = URLComponents()
        components.scheme = "wikipedia"
        components.host = "places"
        var items: [URLQueryItem] = [
            // Use %g-style formatting (no exponent, trims trailing zeros) and a fixed
            // 6-decimal precision
            URLQueryItem(name: "lat", value: format(latitude)),
            URLQueryItem(name: "lon", value: format(longitude))
        ]
        if let name, !name.isEmpty {
            items.append(URLQueryItem(name: "name", value: name))
        }
        components.queryItems = items
        return components.url
    }

    private static func format(_ value: Double) -> String {
        // 6 decimals ≈ 11 cm. Locale-independent (POSIX) so the query string
        // is identical regardless of where the device is.
        value.formatted(
            .number
                .precision(.fractionLength(0...6))
                .grouping(.never)
                .locale(Locale(identifier: "en_US_POSIX"))
        )
    }
}
