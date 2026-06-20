//
//  ParameterValue.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public enum ParameterValue: Sendable, Hashable {

    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([ParameterValue])
    case dictionary([String: ParameterValue])
    case multipart(MultipartFormParameter)
    case multipartList([MultipartFormParameter])

    /// Textual form used for query items and form-url-encoded bodies.
    var queryString: String {
        switch self {
        case .string(let value): return value
        case .int(let value):    return String(value)
        case .double(let value): return String(value)
        case .bool(let value):   return value ? "true" : "false"
        case .array(let items):
            return items.map(\.queryString).joined(separator: ",")
        case .dictionary, .multipart, .multipartList:
            // Not meaningful as a query item; caller has already validated encoding.
            return ""
        }
    }

    /// JSON-encodable form used when building an HTTP body.
    var jsonValue: Any {
        switch self {
        case .string(let value): return value
        case .int(let value):    return value
        case .double(let value): return value
        case .bool(let value):   return value
        case .array(let items):
            return items.map(\.jsonValue)
        case .dictionary(let dict):
            return dict.mapValues(\.jsonValue)
        case .multipart, .multipartList:
            return NSNull()
        }
    }
}

// MARK: - Ergonomic literals

extension ParameterValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self = .string(value) }
}

extension ParameterValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self = .int(value) }
}

extension ParameterValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self = .double(value) }
}

extension ParameterValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self = .bool(value) }
}
