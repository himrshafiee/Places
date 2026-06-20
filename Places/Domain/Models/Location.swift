//
//  Location.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

struct Location: Sendable, Hashable {

    // MARK: Properties
    
    let name: String?
    let latitude: Double
    let longitude: Double

    // MARK: - Init

    init(name: String?, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

}

// MARK: - Decodable

nonisolated extension Location: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "long"
    }
}

extension Location {
    var displayName: String {
        if let name, !name.isEmpty { return name }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
    
    var coordinateDescription: String {
        String(format: "Lat %.4f, Lon %.4f", latitude, longitude)
    }

    var accessibilityCoordinateDescription: String {
        let lat = String(format: "%.2f", latitude)
        let lon = String(format: "%.2f", longitude)
        if let name = name, !name.isEmpty {
            return "\(name). Latitude \(lat), longitude \(lon)."
        }
        return "Latitude \(lat), longitude \(lon)."
    }
}
