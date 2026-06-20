//
//  RepositoriesContainer.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

@MainActor
final class RepositoriesContainer {

    private let networkContainer: NetworkContainer

    init(networkContainer: NetworkContainer) {
        self.networkContainer = networkContainer
    }
    
    lazy var networkLocationsRepository: NetworkLocationsRepositoryProtocol = {
        NetworkLocationsRepository(
            requestManager: networkContainer.requestManager,
            path: "locations.json"
        )
    }()
}
