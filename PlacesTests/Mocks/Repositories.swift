//
//  Repositories.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
@testable import Places

// MARK: - NetworkLocationsRepository

final class MockNetworkLocationsRepository: NetworkLocationsRepositoryProtocol, @unchecked Sendable {
    var stubbedResult: Result<[Location], Error>
    private(set) var callCount = 0

    init(stubbedResult: Result<[Location], Error> = .success([])) {
        self.stubbedResult = stubbedResult
    }

    func fetchLocations() async throws -> [Location] {
        callCount += 1
        return try stubbedResult.get()
    }
}
