//
//  NetworkLocationsRepository.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Networking

// MARK: - Protocol

/// Fetches the list of locations from the assignment endpoint.

protocol NetworkLocationsRepositoryProtocol: Sendable {
    /// Returns the decoded list of `Location`s.
    /// Throws `NetworkError`
    func fetchLocations() async throws -> [Location]
}

// MARK: - Implementation

final class NetworkLocationsRepository: NetworkLocationsRepositoryProtocol {

    private let requestManager: RequestManager
    private let path: String

    /// - Parameters:
    ///   - requestManager: pre-configured request manager (base URL, plugins,  headers all live there).
    ///   - path: the path appended to the manager's base URL.
    init(
        requestManager: RequestManager,
        path: String
    ) {
        self.requestManager = requestManager
        self.path = path
    }

    func fetchLocations() async throws -> [Location] {
        let request = Request(method: .get, path: path)

        let validators: [ResponseValidator] = [
            StatusCodeValidator(),
            NonEmptyBodyValidator()
        ]
        
        return try await requestManager.perform(
            request: request,
            parser: DecodableParser<[Location]>(keyPath: "locations"),
            validators: validators
        )
    }
}
