//
//  HTTPDataLoading.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public protocol HTTPDataLoading: Sendable {
    func loadData(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession conformance

extension URLSession: HTTPDataLoading {
    public func loadData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request)
    }
}
