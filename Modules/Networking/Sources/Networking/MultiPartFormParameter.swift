//
//  MultiPartFormParameter.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public struct MultipartFormParameter: Sendable, Hashable {
    public let data: Data
    public let fileName: String?
    public let mimeType: String?

    public init(data: Data, fileName: String? = nil, mimeType: String? = nil) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
