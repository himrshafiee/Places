//
//  MockURLOpener.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
@testable import Places

// MARK: - URLOpening

@MainActor
final class MockURLOpener: URLOpening {
    var canOpenURLResult: Bool = true
    var openURLResult: Bool = true
    private(set) var openedURLs: [URL] = []
    private(set) var canOpenURLs: [URL] = []

    func canOpen(_ url: URL) -> Bool {
        canOpenURLs.append(url)
        return canOpenURLResult
    }

    func open(_ url: URL) async -> Bool {
        openedURLs.append(url)
        return openURLResult
    }
}
