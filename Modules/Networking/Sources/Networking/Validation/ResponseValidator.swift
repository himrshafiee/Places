//
//  ResponseValidator.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

/// Validates an `HTTPURLResponse` once it has arrived. Implementations must be
/// `Sendable` because the request manager keeps the array of validators on a
/// `Sendable` value and may hand it off across actors.
public protocol ResponseValidator: Sendable {
    func validate(response: HTTPURLResponse, data: Data) throws
}
