//
//  LocationsRouters.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Observation
import SwiftUI



@Observable
@MainActor
final class LocationsRouter {
    
    var path = NavigationPath()
    
    var isCustomLocationSheetPresented: Bool = false

    func presentCustomLocation() { isCustomLocationSheetPresented = true }
    func dismissCustomLocation() { isCustomLocationSheetPresented = false }
    
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func reset() { path = NavigationPath() }
}
