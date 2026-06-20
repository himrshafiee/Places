//
//  LocationsListViewModelTests.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Testing
@testable import Places

@MainActor
@Suite("LocationsListViewModel")
struct LocationsListViewModelTests {

    private func makeSUT(
        fetchResult: Result<[Location], Error> = .success([]),
        openResult: Result<Bool, Error> = .success(true)
    ) -> (LocationsListViewModel, MockFetchLocationsUseCase, MockOpenLocationInWikipediaUseCase) {
        let fetch = MockFetchLocationsUseCase(stubbedResult: fetchResult)
        let open = MockOpenLocationInWikipediaUseCase()
        open.stubbedResult = openResult
        let sut = LocationsListViewModel(
            fetchLocationsUseCase: fetch,
            openLocationUseCase: open
        )
        return (sut, fetch, open)
    }

    // MARK: - load

    @Test("Starts in loading state before load is called")
    func startsInLoadingState() {
        let (sut, _, _) = makeSUT()
        #expect(sut.state == .loading)
    }

    @Test("Transitions to .loaded with the fetched locations on success")
    func loadTransitionsToLoadedOnSuccess() async {
        let locations = [
            Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9),
            Location(name: "Berlin", latitude: 52.52, longitude: 13.40)
        ]
        let (sut, fetch, _) = makeSUT(fetchResult: .success(locations))

        await sut.load()

        #expect(sut.state == .loaded(locations))
        #expect(fetch.callCount == 1)
    }

    @Test("Transitions to .failed with the localized description on error")
    func loadTransitionsToFailedOnError() async {
        struct DummyError: LocalizedError {
            var errorDescription: String? { "boom" }
        }
        let (sut, _, _) = makeSUT(fetchResult: .failure(DummyError()))

        await sut.load()

        guard case .failed(let message) = sut.state else {
            Issue.record("Expected .failed, got \(sut.state)")
            return
        }
        #expect(message == "boom")
    }

    // MARK: - select / openInWikipedia

    @Test("Selecting a location forwards it to the open use case")
    func selectForwardsLocationToOpenUseCase() async {
        let (sut, _, open) = makeSUT(openResult: .success(true))
        let location = Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9)

        await sut.select(location)

        #expect(open.executeCalls == [
            .init(latitude: 52.36, longitude: 4.9, name: "Amsterdam")
        ])
        #expect(sut.wikipediaMissingAlertVisible == false)
        #expect(sut.errorAlertVisible == false)
    }

    @Test("Shows the Wikipedia-missing alert when the opener reports false")
    func selectShowsMissingAlertWhenOpenReturnsFalse() async {
        let (sut, _, _) = makeSUT(openResult: .success(false))
        let location = Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9)

        await sut.select(location)

        #expect(sut.wikipediaMissingAlertVisible == true)
        #expect(sut.errorAlertVisible == false)
    }

    @Test("Shows a coordinate error alert when the open use case throws .invalidCoordinate")
    func selectShowsInvalidCoordinateAlert() async {
        let (sut, _, _) = makeSUT(
            openResult: .failure(OpenLocationInWikipediaError.invalidCoordinate(latitude: 95, longitude: 0))
        )
        let location = Location(name: "Bad", latitude: 95, longitude: 0)

        await sut.select(location)

        #expect(sut.errorAlertVisible == true)
        #expect(sut.errorAlertMessage != nil)
        #expect(sut.wikipediaMissingAlertVisible == false)
    }

    @Test("Shows a generic error alert when the open use case throws an unknown error")
    func selectShowsGenericErrorAlert() async {
        struct DummyError: LocalizedError {
            var errorDescription: String? { "open failed" }
        }
        let (sut, _, _) = makeSUT(openResult: .failure(DummyError()))
        let location = Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9)

        await sut.select(location)

        #expect(sut.errorAlertVisible == true)
        #expect(sut.errorAlertMessage == "open failed")
    }

    // MARK: - error alert lifecycle

    @Test("Clears the error message when the alert is dismissed")
    func clearsErrorMessageWhenAlertDismissed() async {
        struct DummyError: LocalizedError {
            var errorDescription: String? { "open failed" }
        }
        let (sut, _, _) = makeSUT(openResult: .failure(DummyError()))

        await sut.select(Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9))
        #expect(sut.errorAlertMessage == "open failed")

        sut.errorAlertVisible = false

        #expect(sut.errorAlertMessage == nil)
    }
}
