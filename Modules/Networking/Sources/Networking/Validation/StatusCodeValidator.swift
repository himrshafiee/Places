//
//  StatusCodeValidator.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

/// Validates the response status code against an allow-set. 
public struct StatusCodeValidator: ResponseValidator, Sendable {

    public let validStatusCodes: Set<Int>

    public init(validStatusCodes: Range<Int>) {
        self.init(validStatusCodes: Set(validStatusCodes))
    }

    public init(validStatusCodes: Set<Int> = StatusCodeValidator.successCodes) {
        self.validStatusCodes = validStatusCodes
    }

    public func validate(response: HTTPURLResponse, data: Data) throws {
        if !validStatusCodes.contains(response.statusCode) {
            throw NetworkError.badStatus(response.statusCode)
        }
    }
}

public extension StatusCodeValidator {
    static let successCodes: Set<Int> = Set(200..<300)
}
