//
//  FetchLocationsUseCaseTests.swift
//  PlacesTests
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Networking
import Testing
@testable import Places

@Suite("FetchLocationsUseCase")
@MainActor
struct FetchLocationsUseCaseTests {

    @Test("Returns locations from the repository on success")
    func returnsLocationsFromRepository() async throws {
        let locations = [
            Location(name: "Amsterdam", latitude: 52.36, longitude: 4.9),
            Location(name: nil, latitude: 1.0, longitude: 2.0)
        ]
        let repo = MockNetworkLocationsRepository(stubbedResult: .success(locations))
        let sut = FetchLocationsUseCase(networkRepository: repo)

        let result = try await sut.execute()

        #expect(result == locations)
        #expect(repo.callCount == 1)
    }

    @Test("Returns empty array when repository returns no locations")
    func returnsEmptyArray() async throws {
        let repo = MockNetworkLocationsRepository(stubbedResult: .success([]))
        let sut = FetchLocationsUseCase(networkRepository: repo)

        let result = try await sut.execute()

        #expect(result.isEmpty)
        #expect(repo.callCount == 1)
    }

    @Test("Propagates repository error")
    func propagatesRepositoryError() async throws {
        let underlying = NSError(domain: "test", code: 42)
        let repo = MockNetworkLocationsRepository(stubbedResult: .failure(underlying))
        let sut = FetchLocationsUseCase(networkRepository: repo)

        let error = await #expect(throws: NSError.self) {
            _ = try await sut.execute()
        }
        #expect(error?.domain == "test")
        #expect(error?.code == 42)
        #expect(repo.callCount == 1)
    }
    
    @Test("Propagates repository errors")
    func propagatesRepositoryErrors() async throws {
        let underlying = URLError(.notConnectedToInternet)
        let repo = MockNetworkLocationsRepository(
            stubbedResult: .failure(NetworkError.transport(underlying))
        )
        let sut = FetchLocationsUseCase(networkRepository: repo)

        let error = await #expect(throws: NetworkError.self) {
            _ = try await sut.execute()
        }
        guard case .transport(let urlError) = error else {
            Issue.record("Expected .transport, got \(String(describing: error))")
            return
        }
        #expect(urlError.code == .notConnectedToInternet)
        #expect(repo.callCount == 1)
    }

    @Test("Calls the repository once per execute call")
    func callsRepositoryOncePerExecute() async throws {
        let repo = MockNetworkLocationsRepository(stubbedResult: .success([]))
        let sut = FetchLocationsUseCase(networkRepository: repo)

        _ = try await sut.execute()
        _ = try await sut.execute()
        _ = try await sut.execute()

        #expect(repo.callCount == 3)
    }
}
