//
//  Request.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public struct Request: Sendable, Hashable {

    public struct Parameter: Sendable, Hashable {

        public enum Encoding: Sendable, Hashable {
            case query          // → URL query string
            case httpBody       // → JSON body
            case multipartForm  // → multipart/form-data part
        }

        public let key: String
        public let value: ParameterValue
        public let encoding: Encoding

        public init(key: String, value: ParameterValue, encoding: Encoding) {
            self.key = key
            self.value = value
            self.encoding = encoding
        }
    }

    public let method: HTTPMethod
    public let path: String
    public let headers: [String: String]?
    public let parameters: [Parameter]

    public init(
        method: HTTPMethod = .get,
        path: String,
        headers: [String: String]? = nil,
        parameters: [Parameter] = []
    ) {
        self.method = method
        self.path = path
        self.headers = headers
        self.parameters = parameters
    }

    public init(
        method: HTTPMethod = .get,
        path: String,
        headers: [String: String]? = nil,
        parameters: [String: ParameterValue]? = nil,
        encoding: Parameter.Encoding = .query
    ) {
        self.init(
            method: method,
            path: path,
            headers: headers,
            parameters: parameters?.map { Parameter(key: $0.key, value: $0.value, encoding: encoding) } ?? []
        )
    }
}

// MARK: - Parameter filtering helpers

extension Request {

    /// All parameters that should appear in the URL query string.
    var queryParameters: [String: ParameterValue] {
        parameters
            .filter { $0.encoding == .query }
            .reduce(into: [:]) { $0[$1.key] = $1.value }
    }

    /// All parameters destined for the JSON body.
    var bodyParameters: [String: ParameterValue] {
        parameters
            .filter { $0.encoding == .httpBody }
            .reduce(into: [:]) { $0[$1.key] = $1.value }
    }

    /// All multipart parts, grouped by their form field name.
    var multipartParameters: [(name: String, part: MultipartFormParameter)] {
        var parts: [(name: String, part: MultipartFormParameter)] = []
        for parameter in parameters where parameter.encoding == .multipartForm {
            switch parameter.value {
            case .multipart(let part):
                parts.append((parameter.key, part))
            case .multipartList(let list):
                parts.append(contentsOf: list.map { (parameter.key, $0) })
            default:
                assertionFailure(
                    "Multipart form data only accepts ParameterValue.multipart or .multipartList"
                )
            }
        }
        return parts
    }
}
