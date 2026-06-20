//
//  URLRequestBuilderTests.swift
//  NetworkingTests
//

import XCTest
@testable import Networking

final class URLRequestBuilderTests: XCTestCase {

    private let baseURL = URL(string: "https://example.com/v1/")!

    func test_get_with_default_and_request_query_parameters_merges_and_sorts() throws {
        let builder = URLRequestBuilder(
            baseURL: baseURL,
            defaultHeaders: [:],
            defaultParameters: ["api_key": "abc"]
        )
        let request = Request(method: .get, path: "places", parameters: ["q": "amsterdam"])

        let urlRequest = try builder.makeURLRequest(for: request)

        XCTAssertEqual(urlRequest.httpMethod, "GET")
        // Sorted alphabetically so the test is deterministic.
        XCTAssertEqual(
            urlRequest.url?.absoluteString,
            "https://example.com/v1/places?api_key=abc&q=amsterdam"
        )
    }

    func test_request_headers_override_default_headers() throws {
        let builder = URLRequestBuilder(
            baseURL: baseURL,
            defaultHeaders: ["Accept": "application/json", "X-Default": "yes"],
            defaultParameters: [:]
        )
        let request = Request(
            method: .get,
            path: "foo",
            headers: ["Accept": "text/plain"]
        )

        let urlRequest = try builder.makeURLRequest(for: request)

        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Accept"), "text/plain")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Default"), "yes")
    }

    func test_json_body_is_encoded_and_content_type_is_set() throws {
        let builder = URLRequestBuilder(
            baseURL: baseURL,
            defaultHeaders: [:],
            defaultParameters: [:]
        )
        let request = Request(
            method: .post,
            path: "login",
            parameters: ["email": "f@example.com", "remember": true],
            encoding: .httpBody
        )

        let urlRequest = try builder.makeURLRequest(for: request)

        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        let body = try XCTUnwrap(urlRequest.httpBody)
        let parsed = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        XCTAssertEqual(parsed?["email"] as? String, "f@example.com")
        XCTAssertEqual(parsed?["remember"] as? Bool, true)
    }
}
