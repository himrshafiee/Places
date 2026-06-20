//
//  NetworkError.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public enum NetworkError: Error, Sendable {

    /// `URL(string:)` failed or `URLComponents` couldn't be assembled.
    case invalidURL

    /// Server returned a non-2xx status (or whatever the validator considers invalid).
    case badStatus(Int)

    /// Server responded with HTTP 401.
    case unauthorized

    /// Response body was empty when the caller expected something to parse.
    case emptyData

    /// The response was not an `HTTPURLResponse` — usually means the URL
    /// scheme was wrong.
    case nonHTTPResponse

    /// Underlying transport error (network down, DNS, TLS, etc.).
    case transport(URLError)

    /// Decoding the body failed.
    case decoding(Error)

    /// A pluggable interceptor/validator threw.
    case underlying(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Could not build a valid URL for this request."
        case .badStatus(let code): return "Server returned HTTP \(code)."
        case .unauthorized:      return "Authentication required."
        case .emptyData:         return "Server returned an empty response body."
        case .nonHTTPResponse:   return "Received a non-HTTP response."
        case .transport(let error): return error.localizedDescription
        case .decoding(let error):  return error.localizedDescription
        case .underlying(let error): return error.localizedDescription
        }
    }
}
