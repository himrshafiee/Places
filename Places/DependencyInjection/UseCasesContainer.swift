//
//  UseCasesContainer.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import UIKit

@MainActor
final class UseCasesContainer {

    private let repositoriesContainer: RepositoriesContainer

    init(repositoriesContainer: RepositoriesContainer) {
        self.repositoriesContainer = repositoriesContainer
    }
    
    lazy var fetchLocationsUseCase: FetchLocationsUseCaseProtocol = {
        FetchLocationsUseCase(networkRepository: repositoriesContainer.networkLocationsRepository)
    }()
}
