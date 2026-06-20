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
    private let urlOpener: URLOpening

    init(
        repositoriesContainer: RepositoriesContainer,
        urlOpener: URLOpening? = nil
    ) {
        self.repositoriesContainer = repositoriesContainer
        self.urlOpener = urlOpener ??  UIApplicationURLOpener()
    }

    lazy var fetchLocationsUseCase: FetchLocationsUseCaseProtocol = {
        FetchLocationsUseCase(networkRepository: repositoriesContainer.networkLocationsRepository)
    }()

    lazy var openLocationInWikipediaUseCase: OpenLocationInWikipediaUseCaseProtocol = {
        OpenLocationInWikipediaUseCase(opener: urlOpener)
    }()
}

// MARK: - Opener

@MainActor
final class UIApplicationURLOpener: URLOpening {
    func canOpen(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url)
    }

    func open(_ url: URL) async -> Bool {
        await UIApplication.shared.open(url, options: [:])
    }
}

