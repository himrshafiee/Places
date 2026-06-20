//
//  CoordinateParser.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation

enum CoordinateParser {

    /// Parses raw latitude/longitude text. Accepts both '.' and ',' as the
    /// decimal separator and is locale-tolerant (NumberFormatter fallback).
    /// Returns nil if either input fails to parse or falls outside the
    /// WGS84 ranges (-90...90, -180...180).
    static func parse(latitudeText: String, longitudeText: String) -> (latitude: Double, longitude: Double)? {
        guard let lat = parseDouble(latitudeText),
              let lon = parseDouble(longitudeText),
              isValid(latitude: lat, longitude: lon) else {
            return nil
        }
        return (lat, lon)
    }

    static func isValid(latitude: Double, longitude: Double) -> Bool {
        latitude.isFinite && longitude.isFinite
            && (-90.0...90.0).contains(latitude)
            && (-180.0...180.0).contains(longitude)
    }

    private static func parseDouble(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let value = Double(trimmed) { return value }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        if let value = Double(normalized) { return value }
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        return formatter.number(from: trimmed)?.doubleValue
    }
}
