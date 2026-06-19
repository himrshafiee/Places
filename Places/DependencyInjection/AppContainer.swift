//
//  AppContainer.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

@MainActor
final class AppContainer {

    static let shared: AppContainer = AppContainer()

    let appRouter: AppRouter

    private init() {
        self.appRouter = AppRouter()
    }
}
