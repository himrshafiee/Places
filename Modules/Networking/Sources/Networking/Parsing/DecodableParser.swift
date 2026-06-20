//
//  DecodableParser.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

/// Decodes the response body as `ResultType` using `JSONDecoder`. The optional
/// `keyPath` allows pointing at a nested object (dot-separated keys).
public struct DecodableParser<ResultType: Decodable & Sendable>: Parser {

    public let decoder: JSONDecoder
    public let keyPath: String?

    public init(decoder: JSONDecoder = JSONDecoder(), keyPath: String? = nil) {
        self.decoder = decoder
        self.keyPath = keyPath
    }

    public func parse(data: Data) throws -> ResultType {
        guard let keyPath, !keyPath.isEmpty else {
            return try decoder.decode(ResultType.self, from: data)
        }
        let segments = keyPath.split(separator: ".").map(String.init)
        let previous = decoder.userInfo[Self.keyPathUserInfoKey]
        decoder.userInfo[Self.keyPathUserInfoKey] = segments
        defer { decoder.userInfo[Self.keyPathUserInfoKey] = previous }
        return try decoder.decode(KeyPathWrapper.self, from: data).value
    }

    fileprivate static var keyPathUserInfoKey: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "DecodableParser.keyPath")!
    }

    private struct DynamicKey: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }
        init(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    private struct KeyPathWrapper: Decodable {
        let value: ResultType

        init(from decoder: Decoder) throws {
            guard let segments = decoder.userInfo[DecodableParser.keyPathUserInfoKey] as? [String],
                  let last = segments.last else {
                throw ParserError.invalidData
            }
            var container = try decoder.container(keyedBy: DynamicKey.self)
            for segment in segments.dropLast() {
                container = try container.nestedContainer(
                    keyedBy: DynamicKey.self,
                    forKey: DynamicKey(stringValue: segment)
                )
            }
            self.value = try container.decode(ResultType.self, forKey: DynamicKey(stringValue: last))
        }
    }
}
