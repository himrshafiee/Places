//
//  NetworkPlugin.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public protocol NetworkPlugin: Sendable {

    /// Called right before the request is handed to the transport. The plugin
    /// may modify and return a new `URLRequest`. Use this for auth tokens,
    /// device IDs, correlation headers, …
    func prepare(_ request: URLRequest) async throws -> URLRequest

    /// Called after the response arrives and after validation succeeds.
    /// Useful for logging or metrics.
    func didReceive(response: HTTPURLResponse, data: Data, for request: URLRequest) async

    /// Called when the request fails for any reason (transport, validator,
    /// parser). The plugin can inspect the error but cannot recover here 
    /// retries should be implemented as a wrapper plugin around the manager.
    func didFail(with error: Error, for request: URLRequest) async
}

public extension NetworkPlugin {
    func prepare(_ request: URLRequest) async throws -> URLRequest { request }
    func didReceive(response: HTTPURLResponse, data: Data, for request: URLRequest) async {}
    func didFail(with error: Error, for request: URLRequest) async {}
}
