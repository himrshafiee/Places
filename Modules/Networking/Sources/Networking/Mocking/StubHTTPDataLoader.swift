//
//  StubHTTPDataLoader.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation
import os

/// Canned response generator that conforms to `HTTPDataLoading`. Three modes:
/// fixed `data`, on-the-fly closure, or a thrown error. Recorded
/// `capturedRequests` are visible to the caller for assertions.
///
/// Recorded `capturedRequests` are guarded by an `OSAllocatedUnfairLock`,
/// which is async-safe (the critical section never suspends) — so the class
/// is genuinely `Sendable` without the `@unchecked` escape hatch.
public final class StubHTTPDataLoader: HTTPDataLoading, Sendable {

    public enum Behaviour: Sendable {
        case data(Data, statusCode: Int = 200, headers: [String: String]? = nil)
        case error(Error)
    }

    private let capturedRequestsLock = OSAllocatedUnfairLock<[URLRequest]>(initialState: [])
    public var capturedRequests: [URLRequest] {
        capturedRequestsLock.withLock { $0 }
    }

    private let behaviour: Behaviour

    public init(behaviour: Behaviour) {
        self.behaviour = behaviour
    }

    public convenience init(
        data: Data,
        statusCode: Int = 200,
        headers: [String: String]? = nil
    ) {
        self.init(behaviour: .data(data, statusCode: statusCode, headers: headers))
    }

    public convenience init(error: Error) {
        self.init(behaviour: .error(error))
    }

    public func loadData(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequestsLock.withLock { $0.append(request) }

        switch behaviour {
        case .data(let data, let statusCode, let headers):
            let url = request.url ?? URL(string: "https://stub.invalid")!
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            )!
            return (data, response)
        case .error(let error):
            throw error
        }
    }
}
