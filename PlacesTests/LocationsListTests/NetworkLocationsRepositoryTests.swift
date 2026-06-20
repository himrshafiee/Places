//
//  NetworkLocationsRepositoryTests.swift
//  NetworkLocationsRepositoryTests
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Networking
import Testing
@testable import Places

@Suite("NetworkLocationsRepository")
struct NetworkLocationsRepositoryTests {

    private let baseURL = URL(string: "https://example.com/")!
    private let path = "locations.json"

    private func makeRepo(loader: StubHTTPDataLoader) -> NetworkLocationsRepository {
        let manager = RequestManager(baseURL: baseURL, session: loader)
        return NetworkLocationsRepository(requestManager: manager, path: path)
    }

    @Test("Returns decoded locations on 200 success")
    func returnsDecodedLocationsOnSuccess() async throws {
        let json = """
        { "locations": [ { "name": "Amsterdam", "lat": 52.36, "long": 4.9 } ] }
        """.data(using: .utf8)!
        let loader = StubHTTPDataLoader(data: json, statusCode: 200)
        let repo = makeRepo(loader: loader)

        let result = try await repo.fetchLocations()

        #expect(result.count == 1)
        #expect(result.first?.name == "Amsterdam")
        #expect(loader.capturedRequests.first?.url == baseURL.appendingPathComponent(path))
    }
    
    @Test("Returns decoded locations with optional name on 200 success")
    func returnsDecodedLocationsOptionalNameOnSuccess() async throws {
        let json = """
        { "locations": [ { "lat": 52.36, "long": 4.9 } ] }
        """.data(using: .utf8)!
        let loader = StubHTTPDataLoader(data: json, statusCode: 200)
        let repo = makeRepo(loader: loader)

        let result = try await repo.fetchLocations()

        #expect(result.count == 1)
        #expect(result.first?.name == nil)
        #expect(result.first?.latitude == Double(52.36))
        #expect(result.first?.longitude == Double(4.9))
    }

    @Test("Throws .badStatus on non-2xx response")
    func throwsBadStatusOnNon2xx() async throws {
        let loader = StubHTTPDataLoader(data: Data("{}".utf8), statusCode: 503)
        let repo = makeRepo(loader: loader)

        let error = await #expect(throws: NetworkError.self) {
            _ = try await repo.fetchLocations()
        }
        guard case .badStatus(let code) = error else {
            Issue.record("Expected .badStatus, got \(String(describing: error))")
            return
        }
        #expect(code == 503)
    }

    @Test("Throws .emptyData when the response body is empty")
    func throwsEmptyDataWhenBodyEmpty() async throws {
        let loader = StubHTTPDataLoader(data: Data(), statusCode: 200)
        let repo = makeRepo(loader: loader)

        let error = await #expect(throws: NetworkError.self) {
            _ = try await repo.fetchLocations()
        }
        guard case .emptyData = error else {
            Issue.record("Expected .emptyData, got \(String(describing: error))")
            return
        }
    }

    @Test("Propagates URLError as .transport")
    func propagatesTransportError() async throws {
        let underlying = URLError(.notConnectedToInternet)
        let loader = StubHTTPDataLoader(error: underlying)
        let repo = makeRepo(loader: loader)

        let error = await #expect(throws: NetworkError.self) {
            _ = try await repo.fetchLocations()
        }
        guard case .transport(let urlError) = error else {
            Issue.record("Expected .transport, got \(String(describing: error))")
            return
        }
        #expect(urlError.code == .notConnectedToInternet)
    }

    @Test("Propagates decoding failure as .decoding")
    func propagatesDecodingErrorOnMalformedJSON() async throws {
        let loader = StubHTTPDataLoader(data: Data("not json".utf8), statusCode: 200)
        let repo = makeRepo(loader: loader)

        let error = await #expect(throws: NetworkError.self) {
            _ = try await repo.fetchLocations()
        }
        guard case .decoding = error else {
            Issue.record("Expected .decoding, got \(String(describing: error))")
            return
        }
    }
}
