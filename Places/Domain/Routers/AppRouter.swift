//
//  AppRouter.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Observation
import SwiftUI

enum AppFlow: Equatable {
    case splashScreen
    case locations
}

@Observable
@MainActor
final class AppRouter {
    var currentFlow: AppFlow

    init(initialFlow: AppFlow = .splashScreen) {
        self.currentFlow = initialFlow
    }

    func finishSplash() {
        currentFlow = .locations
    }
}
