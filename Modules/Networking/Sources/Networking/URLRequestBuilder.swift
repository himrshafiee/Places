//
//  URLRequestBuilder.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

struct URLRequestBuilder: Sendable {

    let baseURL: URL
    let defaultHeaders: [String: String]
    let defaultParameters: [String: ParameterValue]

    func makeURLRequest(for request: Request) throws -> URLRequest {

        // MARK: URL + query string

        let baseWithPath: URL = {
            if request.path.isEmpty { return baseURL }
            return baseURL.appendingPathComponent(request.path)
        }()

        guard var components = URLComponents(url: baseWithPath, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        let mergedQuery = merge(defaultParameters, request.queryParameters)
        if !mergedQuery.isEmpty {
            components.queryItems = mergedQuery
                .map { URLQueryItem(name: $0.key, value: $0.value.queryString) }
                .sorted { $0.name < $1.name }
        }

        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }

        // MARK: URLRequest assembly

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue

        // Headers: defaults first, then per-request overrides.
        for (key, value) in defaultHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        if let perRequest = request.headers {
            for (key, value) in perRequest {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        // MARK: Body — JSON or multipart

        let multipart = request.multipartParameters
        let body = request.bodyParameters

        switch (body.isEmpty, multipart.isEmpty) {
        case (true, true):
            break // No body — fine for GET/HEAD/etc.
        case (false, true):
            urlRequest.httpBody = try encodeJSON(body)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        case (true, false):
            let (data, contentType) = MultipartEncoder.encode(parts: multipart)
            urlRequest.httpBody = data
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        case (false, false):
            assertionFailure(
                "Both JSON body parameters and multipart parameters supplied — JSON will be ignored"
            )
            let (data, contentType) = MultipartEncoder.encode(parts: multipart)
            urlRequest.httpBody = data
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }

    // MARK: - Helpers

    private func encodeJSON(_ body: [String: ParameterValue]) throws -> Data {
        let json = body.mapValues(\.jsonValue)
        return try JSONSerialization.data(withJSONObject: json)
    }

    private func merge<Value>(_ lhs: [String: Value], _ rhs: [String: Value]) -> [String: Value] {
        lhs.merging(rhs) { _, new in new }
    }
}
