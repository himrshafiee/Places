//
//  OpenLocationInWikipediaUseCaseTests.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Testing
@testable import Places

@MainActor
@Suite("OpenLocationInWikipediaUseCase")
struct OpenLocationInWikipediaUseCaseTests {

    private func makeSUT() -> (OpenLocationInWikipediaUseCase, MockURLOpener) {
        let opener = MockURLOpener()
        let sut = OpenLocationInWikipediaUseCase(opener: opener)
        return (sut, opener)
    }

    // MARK: - execute

    @Test("Opens a wikipedia://places URL with lat/lon for a valid location without a name")
    func opensURLWithoutNameWhenNameIsNil() async throws {
        let (sut, opener) = makeSUT()
        let location = Location(name: nil, latitude: 52.36, longitude: 4.9)

        let result = try await sut.execute(location: location)

        #expect(result == true)
        #expect(opener.openedURLs.count == 1)
        let url = try #require(opener.openedURLs.first)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.scheme == "wikipedia")
        #expect(components.host == "places")
        let items = components.queryItems ?? []
        #expect(items.contains(URLQueryItem(name: "lat", value: "52.36")))
        #expect(items.contains(URLQueryItem(name: "lon", value: "4.9")))
        #expect(items.first(where: { $0.name == "name" }) == nil)
    }

    @Test("Includes the name query item when the location has a non-empty name")
    func includesNameQueryItemWhenNamePresent() async throws {
        let (sut, opener) = makeSUT()
        let location = Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9)

        let result = try await sut.execute(location: location)

        #expect(result == true)
        let url = try #require(opener.openedURLs.first)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = components.queryItems ?? []
        #expect(items.contains(URLQueryItem(name: "name", value: "Amsterdam")))
    }

    @Test("Returns false when the opener reports failure but still attempts to open")
    func returnsFalseWhenOpenerFails() async throws {
        let (sut, opener) = makeSUT()
        opener.openURLResult = false
        let location = Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9)

        let result = try await sut.execute(location: location)

        #expect(result == false)
        #expect(opener.openedURLs.count == 1)
    }

    @Test("Throws .invalidCoordinate when latitude is out of range")
    func throwsForInvalidLatitude() async throws {
        let (sut, opener) = makeSUT()
        let location = Location(name: "Invalid", latitude: 95.0, longitude: 4.9)

        let error = await #expect(throws: OpenLocationInWikipediaError.self) {
            _ = try await sut.execute(location: location)
        }
        #expect(error == .invalidCoordinate(latitude: 95.0, longitude: 4.9))
        #expect(opener.openedURLs.isEmpty)
    }

    @Test("Throws .invalidCoordinate when longitude is out of range")
    func throwsForInvalidLongitude() async throws {
        let (sut, opener) = makeSUT()
        let location = Location(name: "Invalid", latitude: 0, longitude: -200)

        let error = await #expect(throws: OpenLocationInWikipediaError.self) {
            _ = try await sut.execute(location: location)
        }
        #expect(error == .invalidCoordinate(latitude: 0, longitude: -200))
        #expect(opener.openedURLs.isEmpty)
    }

    @Test("Throws .invalidCoordinate for non-finite coordinates")
    func throwsForNonFiniteCoordinates() async throws {
        let (sut, opener) = makeSUT()
        let location = Location(name: "NaN", latitude: .nan, longitude: 0)

        await #expect(throws: OpenLocationInWikipediaError.self) {
            _ = try await sut.execute(location: location)
        }
        #expect(opener.openedURLs.isEmpty)
    }

    // MARK: - isWikipediaInstalled

    @Test("Reports installed when opener canOpen returns true")
    func reportsInstalledWhenOpenerSaysYes() {
        let (sut, opener) = makeSUT()
        opener.canOpenURLResult = true

        #expect(sut.isWikipediaInstalled() == true)
        #expect(opener.canOpenURLs.first?.scheme == "wikipedia")
    }

    @Test("Reports not installed when opener canOpen returns false")
    func reportsNotInstalledWhenOpenerSaysNo() {
        let (sut, opener) = makeSUT()
        opener.canOpenURLResult = false

        #expect(sut.isWikipediaInstalled() == false)
        #expect(opener.canOpenURLs.count == 1)
    }

    // MARK: - URL formatter

    @Test("Formats coordinates to at most 6 decimals with no grouping, locale-independent")
    func formatsCoordinatesWithExpectedPrecision() throws {
        let url = try #require(
            OpenLocationInWikipediaUseCase.makeWikipediaPlacesURL(
                latitude: 52.123456789,
                longitude: -4.0,
                name: nil
            )
        )
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = components.queryItems ?? []
        #expect(items.contains(URLQueryItem(name: "lat", value: "52.123457")))
        #expect(items.contains(URLQueryItem(name: "lon", value: "-4")))
    }
}
