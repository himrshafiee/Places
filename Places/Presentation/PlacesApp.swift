//
//  PlacesApp.swift
//  Places
//
//  Created by Amin Shafiee on 19/06/2026.
//

import SwiftUI

@main
struct PlacesApp: App {
    @State private var appRouter: AppRouter = AppContainer.shared.appRouter
    
    var body: some Scene {
        WindowGroup {
            ContentView(appRouter: appRouter)
        }
    }
}

struct ContentView: View {
    @Bindable var appRouter: AppRouter

    var body: some View {
        switch appRouter.currentFlow {
        case .splashScreen:
            SplashView(onFinished: appRouter.finishSplash)
                .transition(.opacity)
        case .locations:
            LocationsListView(
                router: appRouter.locationsRouter,
                viewModelsContainer: AppContainer.shared.viewModels
            )
        }
    }
}
