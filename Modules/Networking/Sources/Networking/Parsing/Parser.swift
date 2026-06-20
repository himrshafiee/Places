//
//  Parser.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public enum ParserError: Error, Sendable {
    case invalidData
}

/// Strategy that converts a raw `Data` body into a typed value.
public protocol Parser: Sendable {
    associatedtype ResultType: Sendable
    func parse(data: Data) throws -> ResultType
}
