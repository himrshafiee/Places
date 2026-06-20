//
//  RequestManager.swift
//  Networking
//
//  Created by Amin Shafiee
//

import Foundation

public final class RequestManager: Sendable {

    // MARK: - Constants

    public static let defaultResponseValidators: [ResponseValidator] = [StatusCodeValidator()]

    // MARK: - Public properties

    public let baseURL: URL

    // MARK: - Private properties

    private let session: HTTPDataLoading
    private let defaultHeaders: @Sendable () -> [String: String]
    private let defaultParameters: @Sendable () -> [String: ParameterValue]
    private let plugins: [NetworkPlugin]

    // MARK: - Init

    /// Designated initialiser.
    /// - Parameters:
    ///   - baseURL: every `Request.path` is appended to this URL.
    ///   - session: the HTTP transport. Default `URLSession.shared`; injectable for tests.
    ///   - defaultHeaders: closure returning the headers that should be added to every request.
    ///     Per-request headers with the same key override these.
    ///   - defaultParameters: closure returning the query parameters that should be added to every
    ///     request. Per-request parameters with the same key override these.
    ///   - plugins: hooks that run around every request. Order matters — they fire in array order.
    public init(
        baseURL: URL,
        session: HTTPDataLoading = URLSession.shared,
        defaultHeaders: @escaping @Sendable () -> [String: String] = { [:] },
        defaultParameters: @escaping @Sendable () -> [String: ParameterValue] = { [:] },
        plugins: [NetworkPlugin] = []
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
        self.defaultParameters = defaultParameters
        self.plugins = plugins
    }

    // MARK: - Perform

    /// Performs the request and returns the raw response body. Throws
    /// `NetworkError` on transport, validation, or plugin failure.
    @discardableResult
    public func perform(
        request: Request,
        validators: [ResponseValidator] = RequestManager.defaultResponseValidators
    ) async throws -> Data {

        let builder = URLRequestBuilder(
            baseURL: baseURL,
            defaultHeaders: defaultHeaders(),
            defaultParameters: defaultParameters()
        )

        var urlRequest = try builder.makeURLRequest(for: request)

        for plugin in plugins {
            urlRequest = try await plugin.prepare(urlRequest)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.loadData(for: urlRequest)
        } catch let urlError as URLError {
            await notifyFailure(NetworkError.transport(urlError), urlRequest: urlRequest)
            throw NetworkError.transport(urlError)
        } catch {
            await notifyFailure(error, urlRequest: urlRequest)
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            let error = NetworkError.nonHTTPResponse
            await notifyFailure(error, urlRequest: urlRequest)
            throw error
        }

        if httpResponse.statusCode == 401 {
            let error = NetworkError.unauthorized
            await notifyFailure(error, urlRequest: urlRequest)
            throw error
        }

        do {
            for validator in validators {
                try validator.validate(response: httpResponse, data: data)
            }
        } catch let networkError as NetworkError {
            await notifyFailure(networkError, urlRequest: urlRequest)
            throw networkError
        } catch {
            let wrapped = NetworkError.underlying(error)
            await notifyFailure(wrapped, urlRequest: urlRequest)
            throw wrapped
        }

        for plugin in plugins {
            await plugin.didReceive(response: httpResponse, data: data, for: urlRequest)
        }

        return data
    }

    /// Performs the request and parses the response body with the supplied parser.
    public func perform<P: Parser>(
        request: Request,
        parser: P,
        validators: [ResponseValidator] = RequestManager.defaultResponseValidators
    ) async throws -> P.ResultType {
        let data = try await perform(request: request, validators: validators)
        do {
            return try parser.parse(data: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decoding(decodingError)
        } catch {
            throw NetworkError.underlying(error)
        }
    }

    // MARK: - Helpers

    private func notifyFailure(_ error: Error, urlRequest: URLRequest) async {
        for plugin in plugins {
            await plugin.didFail(with: error, for: urlRequest)
        }
    }
}
