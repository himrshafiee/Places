//
//  AddCustomLocationViewModel.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AddCustomLocationViewModel {

    // MARK: - Form properties
    
    var latitudeText: String = "" {
        didSet { refreshValidationMessage() }
    }
    var longitudeText: String = "" {
        didSet { refreshValidationMessage() }
    }
    var nameText: String = "" {
        didSet { refreshValidationMessage() }
    }

    /// Error shown beneath the form. Cleared whenever inputs change.
    private(set) var validationMessage: String?

    var canSubmit: Bool {
        parseCoordinates() != nil
    }

    // MARK: - Dependencies

    private let openLocationUseCase: OpenLocationInWikipediaUseCaseProtocol

    let onOpened: @MainActor () -> Void
    let onWikipediaMissing: @MainActor () -> Void

    init(
        openLocationUseCase: OpenLocationInWikipediaUseCaseProtocol,
        onOpened: @escaping @MainActor () -> Void,
        onWikipediaMissing: @escaping @MainActor () -> Void
    ) {
        self.openLocationUseCase = openLocationUseCase
        self.onOpened = onOpened
        self.onWikipediaMissing = onWikipediaMissing
    }

    // MARK: - Intents

    func submit() async {
        guard let (lat, lon) = parseCoordinates() else {
            validationMessage = String.localized(.coordinateIsNotValid)
            return
        }
        validationMessage = nil
        let trimmedName = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        let name: String? = trimmedName.isEmpty ? nil : trimmedName
        do {
            let opened = try await openLocationUseCase.execute(location: Location(name: name, latitude: lat, longitude: lon))
            if opened {
                onOpened()
            } else {
                onWikipediaMissing()
            }
        } catch {
            validationMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers
    
    private func refreshValidationMessage() {
        if latitudeText.isEmpty || longitudeText.isEmpty {
            validationMessage = nil
        } else if parseCoordinates() == nil {
            validationMessage = String.localized(.coordinateIsNotValid)
        } else {
            validationMessage = nil
        }
    }

    /// Returns the parsed coordinate pair if both inputs are valid lat/lon Doubles
    private func parseCoordinates() -> (Double, Double)? {
        guard let coordinate = CoordinateParser.parse(latitudeText: latitudeText, longitudeText: longitudeText) else {
            return nil
        }
        return (coordinate.latitude, coordinate.longitude)
    }
}
