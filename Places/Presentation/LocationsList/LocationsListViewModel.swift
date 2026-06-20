//
//  LocationsListViewModel.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Networking
import Observation

@MainActor
@Observable
final class LocationsListViewModel {

    // MARK: - View states

    enum ViewState: Equatable {
        case loading
        case loaded([Location])
        case failed(String)
    }

    private(set) var state: ViewState = .loading

    // MARK: - Dependencies

    private let fetchLocationsUseCase: FetchLocationsUseCaseProtocol

    init(
        fetchLocationsUseCase: FetchLocationsUseCaseProtocol
    ) {
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }

    func load() async {
        state = .loading
        do {
            let items = try await fetchLocationsUseCase.execute()
            state = .loaded(items)
        } catch is CancellationError {
            // The user navigated away or triggered a fresh load — leave state alone.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func select(_ location: Location) async {
    }

}
