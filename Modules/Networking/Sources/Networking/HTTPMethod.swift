//
//  HTTPMethod.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public enum HTTPMethod: String, Sendable, Hashable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
