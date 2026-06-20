//
//  UseCases.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
@testable import Places

// MARK: - UseCases

final class MockFetchLocationsUseCase: FetchLocationsUseCaseProtocol, @unchecked Sendable {
    var stubbedResult: Result<[Location], Error>
    private(set) var callCount = 0

    init(stubbedResult: Result<[Location], Error> = .success([])) {
        self.stubbedResult = stubbedResult
    }

    func execute() async throws -> [Location] {
        callCount += 1
        return try stubbedResult.get()
    }
}

final class MockOpenLocationInWikipediaUseCase: OpenLocationInWikipediaUseCaseProtocol, @unchecked Sendable {
    struct ExecuteCall: Equatable {
        let latitude: Double
        let longitude: Double
        let name: String?
    }

    var stubbedResult: Result<Bool, Error> = .success(true)
    var stubbedIsInstalled: Bool = true
    private(set) var executeCalls: [ExecuteCall] = []
    private(set) var isInstalledCallCount = 0

    func execute(latitude: Double, longitude: Double, name: String?) async throws -> Bool {
        executeCalls.append(.init(latitude: latitude, longitude: longitude, name: name))
        return try stubbedResult.get()
    }

    func execute(location: Location) async throws -> Bool {
        try await execute(
            latitude: location.latitude,
            longitude: location.longitude,
            name: location.name
        )
    }

    func isWikipediaInstalled() -> Bool {
        isInstalledCallCount += 1
        return stubbedIsInstalled
    }
}
