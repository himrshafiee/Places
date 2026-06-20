//
//  MultiPartEncoder.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

enum MultipartEncoder {

    /// Encodes the supplied parts into a `Data` payload plus the matching
    /// `Content-Type` header value (which carries the boundary string).
    static func encode(parts: [(name: String, part: MultipartFormParameter)]) -> (data: Data, contentType: String) {
        let boundary = "PlacesAppBoundary-\(UUID().uuidString)"
        var body = Data()

        for (name, part) in parts {
            body.appendString("--\(boundary)\r\n")

            var disposition = "Content-Disposition: form-data; name=\"\(name)\""
            if let fileName = part.fileName {
                disposition += "; filename=\"\(fileName)\""
            }
            body.appendString(disposition + "\r\n")

            if let mimeType = part.mimeType {
                body.appendString("Content-Type: \(mimeType)\r\n")
            }
            body.appendString("\r\n")
            body.append(part.data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")

        return (body, "multipart/form-data; boundary=\(boundary)")
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
