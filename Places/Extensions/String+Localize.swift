//
//  String+Localize.swift
//  Places
//
//  Created by Amin Shafiee on 19/06/2026.
//

import Foundation

extension String {
    
    enum TranslationKey: String, CaseIterable {

        // MARK: General
        case tryAgain
        
        // MARK: SplashView
        case splashViewTitle
        case splashAccessibilityLabel
        
        // MARK: LocationsList
        case locationsListNavigationTitle
        case locationsListLoadingText
        case locationsListLoadingTextAccessibilityLabel
        case locationsListEmptyTitle
        case locationListEmptyDescription
        case locationListError
        case locationsListRowViewAccessibilityHint
    }

    /// Returns the localized string for the given key.
    static func localized(_ key: TranslationKey, bundle: Bundle = .main) -> String {
        let value = NSLocalizedString(
            key.rawValue,
            tableName: nil,
            bundle: bundle,
            value: "",
            comment: ""
        )

        guard value != key.rawValue, !value.isEmpty else {
            assertionFailure("Localized string not found for the key \(key.rawValue)")
            return key.rawValue
        }
        return value
    }
}
