//
//  NetworkLogger.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation
import os

/// Default logger plugin. Uses `os.Logger` so output lands in the unified
/// logging system on device.
public struct NetworkLogger: NetworkPlugin {

    /// What to print. Use `.verbose` while debugging, `.minimal` in builds you
    /// ship to TestFlight.
    public enum Verbosity: Sendable {
        case minimal   // method + URL + status code
        case verbose   // also headers + body (truncated)
    }

    private let logger: Logger
    private let verbosity: Verbosity
    private let maxBodyLength: Int

    public init(
        subsystem: String = "shafi.ee.iOSApp",
        category: String = "Network",
        verbosity: Verbosity = .minimal,
        maxBodyLength: Int = 2_048
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.verbosity = verbosity
        self.maxBodyLength = maxBodyLength
    }

    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "<nil>"
        switch verbosity {
        case .minimal:
            logger.debug("→ \(method, privacy: .public) \(url, privacy: .public)")
        case .verbose:
            let headers = request.allHTTPHeaderFields ?? [:]
            let bodyPreview = preview(request.httpBody)
            logger.debug("""
                → \(method, privacy: .public) \(url, privacy: .public)
                headers=\(headers, privacy: .public)
                body=\(bodyPreview, privacy: .public)
                """)
        }
        return request
    }

    public func didReceive(response: HTTPURLResponse, data: Data, for request: URLRequest) async {
        let url = request.url?.absoluteString ?? "<nil>"
        switch verbosity {
        case .minimal:
            logger.debug("← \(response.statusCode) \(url, privacy: .public)")
        case .verbose:
            logger.debug("""
                ← \(response.statusCode) \(url, privacy: .public)
                body=\(self.preview(data), privacy: .public)
                """)
        }
    }

    public func didFail(with error: Error, for request: URLRequest) async {
        let url = request.url?.absoluteString ?? "<nil>"
        logger.error("✗ \(url, privacy: .public) — \(String(describing: error), privacy: .public)")
    }

    private func preview(_ data: Data?) -> String {
        guard let data, !data.isEmpty else { return "<empty>" }
        let trimmed = data.prefix(maxBodyLength)
        if let string = String(data: trimmed, encoding: .utf8) {
            return string + (data.count > maxBodyLength ? "…(truncated)" : "")
        }
        return "<\(data.count) bytes>"
    }
}
