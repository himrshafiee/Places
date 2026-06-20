//
//  RequestManagerTests.swift
//  NetworkingTests
//

import XCTest
@testable import Networking

final class RequestManagerTests: XCTestCase {

    private let baseURL = URL(string: "https://example.com/")!

    // MARK: - Decodable parsing

    func test_perform_with_parser_decodes_json_body() async throws {
        struct Payload: Decodable, Sendable, Equatable { let id: Int; let name: String }
        let json = #"{"id":42,"name":"Amsterdam"}"#.data(using: .utf8)!
        let loader = StubHTTPDataLoader(data: json, statusCode: 200)
        let sut = RequestManager(baseURL: baseURL, session: loader)

        let payload: Payload = try await sut.perform(
            request: Request(method: .get, path: "things/42"),
            parser: DecodableParser<Payload>()
        )

        XCTAssertEqual(payload, Payload(id: 42, name: "Amsterdam"))
        XCTAssertEqual(loader.capturedRequests.first?.url?.path, "/things/42")
    }

    // MARK: - Validators

    func test_default_validator_throws_badStatus_on_5xx() async {
        let loader = StubHTTPDataLoader(data: Data("oops".utf8), statusCode: 502)
        let sut = RequestManager(baseURL: baseURL, session: loader)

        do {
            _ = try await sut.perform(request: Request(path: ""))
            XCTFail("Expected throw")
        } catch NetworkError.badStatus(let code) {
            XCTAssertEqual(code, 502)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    // MARK: - 401 surfaces as typed unauthorized error

    func test_401_throws_unauthorized() async {
        let loader = StubHTTPDataLoader(data: Data(), statusCode: 401)
        let sut = RequestManager(baseURL: baseURL, session: loader)

        do {
            _ = try await sut.perform(request: Request(path: "x"))
            XCTFail("Expected throw")
        } catch NetworkError.unauthorized {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
}
