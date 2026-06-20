//
//  ViewModelsContainer.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

@MainActor
final class ViewModelsContainer {

    private let useCasesContainer: UseCasesContainer

    init(useCasesContainer: UseCasesContainer) {
        self.useCasesContainer = useCasesContainer
    }
    
    func makeLocationsListViewModel() -> LocationsListViewModel {
        LocationsListViewModel(
            fetchLocationsUseCase: useCasesContainer.fetchLocationsUseCase
        )
    }
}
