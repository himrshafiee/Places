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
    private(set) var errorAlertMessage: String?

    var wikipediaMissingAlertVisible: Bool = false
    var errorAlertVisible: Bool = false {
        didSet {
            if !errorAlertVisible { errorAlertMessage = nil }
        }
    }

    private func showErrorAlert(_ message: String) {
        errorAlertMessage = message
        errorAlertVisible = true
    }

    // MARK: - Dependencies

    private let fetchLocationsUseCase: FetchLocationsUseCaseProtocol
    private let openLocationUseCase: OpenLocationInWikipediaUseCaseProtocol
    
    init(
        fetchLocationsUseCase: FetchLocationsUseCaseProtocol,
        openLocationUseCase: OpenLocationInWikipediaUseCaseProtocol
    ) {
        self.fetchLocationsUseCase = fetchLocationsUseCase
        self.openLocationUseCase = openLocationUseCase
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
        await openInWikipedia(location: location)
    }


    // MARK: - Private functions

    private func openInWikipedia(location: Location) async {
        do {
            let opened = try await openLocationUseCase.execute(location: location)
            if !opened {
                wikipediaMissingAlertVisible = true
            }
        } catch {
            showErrorAlert(error.localizedDescription)
        }
    }

}
