//
//  FetchLocationsUseCase.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

// MARK: - Protocol

protocol FetchLocationsUseCaseProtocol: Sendable {
    func execute() async throws -> [Location]
}

// MARK: - Implementation

@MainActor
final class FetchLocationsUseCase: FetchLocationsUseCaseProtocol {

    private let networkRepository: NetworkLocationsRepositoryProtocol

    init(networkRepository: NetworkLocationsRepositoryProtocol) {
        self.networkRepository = networkRepository
    }

    func execute() async throws -> [Location] {
        try await networkRepository.fetchLocations()
    }
}
