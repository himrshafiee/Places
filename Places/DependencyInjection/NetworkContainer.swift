//
//  NetworkContainer.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Networking

@MainActor
final class NetworkContainer {
    
    // MARK: Properties
    
    let baseURL: URL
    let requestManager: RequestManager

    init(
        baseURL: URL = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/")!,
        session: HTTPDataLoading = URLSession.shared,
        plugins: [NetworkPlugin] = [NetworkLogger(verbosity: .minimal)]
    ) {
        self.baseURL = baseURL
        self.requestManager = RequestManager(
            baseURL: baseURL,
            session: session,
            defaultHeaders: { ["Accept": "application/json"] },
            plugins: plugins
        )
    }
}
