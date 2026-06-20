//
//  RawDataParser.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

/// Returns the body bytes unmodified.
public struct RawDataParser: Parser {
    public init() {}
    public func parse(data: Data) throws -> Data { data }
}
