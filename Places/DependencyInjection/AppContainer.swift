//
//  AppContainer.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

@MainActor
final class AppContainer {

    static let shared: AppContainer = AppContainer()

    let appRouter: AppRouter
    let networkContainer: NetworkContainer
    let repositories: RepositoriesContainer
    let useCases: UseCasesContainer
    let viewModels: ViewModelsContainer

    private init() {
        self.appRouter = AppRouter()
        self.networkContainer = NetworkContainer()
        self.repositories = RepositoriesContainer(networkContainer: networkContainer)
        self.useCases = UseCasesContainer(repositoriesContainer: repositories)
        self.viewModels = ViewModelsContainer(useCasesContainer: useCases)
    }
}
