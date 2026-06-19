//
//  SplashView.swift
//  Places
//
//  Created by Amin Shafiee on 19/06/2026.
//

import SwiftUI

struct SplashView: View {
    
    /// How long the splash stays on screen before signalling completion.
    var duration: Duration = .seconds(1.5)

    /// Called once the splash duration elapses. Wrapped in `withAnimation` so
    /// the parent's flow transition animates.
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color(.SplashScreen.background)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .foregroundStyle(Color(.SplashScreen.logo))
                    .accessibilityHidden(true)

                Text("Places")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Color(.SplashScreen.title))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Places. Loading.")
        .accessibilityAddTraits(.isHeader)
        .task {
            try? await Task.sleep(for: duration)
            withAnimation(.easeInOut(duration: 0.35)) {
                onFinished()
            }
        }
    }
}
