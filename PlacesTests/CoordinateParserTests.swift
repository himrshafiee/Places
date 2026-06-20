//
//  CoordinateParserTests.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Testing
@testable import Places

@Suite("CoordinateParser")
struct CoordinateParserTests {

    // MARK: - parse

    @Test("Parses dot-separated decimals")
    func parsesDotSeparatedDecimals() throws {
        let parsed = try #require(CoordinateParser.parse(latitudeText: "52.36", longitudeText: "4.9"))
        #expect(parsed.latitude == 52.36)
        #expect(parsed.longitude == 4.9)
    }

    @Test("Parses comma-separated decimals by normalizing to dot")
    func parsesCommaSeparatedDecimals() throws {
        let parsed = try #require(CoordinateParser.parse(latitudeText: "52,36", longitudeText: "4,9"))
        #expect(parsed.latitude == 52.36)
        #expect(parsed.longitude == 4.9)
    }

    @Test("Parses negative values")
    func parsesNegativeValues() throws {
        let parsed = try #require(CoordinateParser.parse(latitudeText: "-33.86", longitudeText: "-70.66"))
        #expect(parsed.latitude == -33.86)
        #expect(parsed.longitude == -70.66)
    }

    @Test("Trims surrounding whitespace")
    func trimsSurroundingWhitespace() throws {
        let parsed = try #require(CoordinateParser.parse(latitudeText: "  52.36  ", longitudeText: "\t4.9\n"))
        #expect(parsed.latitude == 52.36)
        #expect(parsed.longitude == 4.9)
    }

    @Test("Parses integer-only strings")
    func parsesIntegerStrings() throws {
        let parsed = try #require(CoordinateParser.parse(latitudeText: "0", longitudeText: "180"))
        #expect(parsed.latitude == 0)
        #expect(parsed.longitude == 180)
    }

    @Test("Accepts boundary values for latitude and longitude")
    func acceptsBoundaryValues() throws {
        #expect(CoordinateParser.parse(latitudeText: "-90", longitudeText: "-180") != nil)
        #expect(CoordinateParser.parse(latitudeText: "90", longitudeText: "180") != nil)
    }

    @Test("Returns nil when either input is empty")
    func returnsNilForEmptyInput() {
        #expect(CoordinateParser.parse(latitudeText: "", longitudeText: "4.9") == nil)
        #expect(CoordinateParser.parse(latitudeText: "52.36", longitudeText: "") == nil)
        #expect(CoordinateParser.parse(latitudeText: "   ", longitudeText: "4.9") == nil)
    }

    @Test("Returns nil for non-numeric input")
    func returnsNilForNonNumericInput() {
        #expect(CoordinateParser.parse(latitudeText: "abc", longitudeText: "4.9") == nil)
        #expect(CoordinateParser.parse(latitudeText: "52.36", longitudeText: "xyz") == nil)
    }

    @Test("Returns nil when latitude is out of range")
    func returnsNilWhenLatitudeOutOfRange() {
        #expect(CoordinateParser.parse(latitudeText: "90.0001", longitudeText: "0") == nil)
        #expect(CoordinateParser.parse(latitudeText: "-90.0001", longitudeText: "0") == nil)
    }

    @Test("Returns nil when longitude is out of range")
    func returnsNilWhenLongitudeOutOfRange() {
        #expect(CoordinateParser.parse(latitudeText: "0", longitudeText: "180.0001") == nil)
        #expect(CoordinateParser.parse(latitudeText: "0", longitudeText: "-180.0001") == nil)
    }

    // MARK: - isValid

    @Test("isValid accepts in-range, finite coordinates")
    func isValidAcceptsInRangeFinite() {
        #expect(CoordinateParser.isValid(latitude: 0, longitude: 0))
        #expect(CoordinateParser.isValid(latitude: 52.36, longitude: 4.9))
        #expect(CoordinateParser.isValid(latitude: -90, longitude: -180))
        #expect(CoordinateParser.isValid(latitude: 90, longitude: 180))
    }

    @Test("isValid rejects out-of-range coordinates")
    func isValidRejectsOutOfRange() {
        #expect(!CoordinateParser.isValid(latitude: 90.0001, longitude: 0))
        #expect(!CoordinateParser.isValid(latitude: -90.0001, longitude: 0))
        #expect(!CoordinateParser.isValid(latitude: 0, longitude: 180.0001))
        #expect(!CoordinateParser.isValid(latitude: 0, longitude: -180.0001))
    }

    @Test("isValid rejects non-finite coordinates")
    func isValidRejectsNonFinite() {
        #expect(!CoordinateParser.isValid(latitude: .nan, longitude: 0))
        #expect(!CoordinateParser.isValid(latitude: 0, longitude: .nan))
        #expect(!CoordinateParser.isValid(latitude: .infinity, longitude: 0))
        #expect(!CoordinateParser.isValid(latitude: 0, longitude: -.infinity))
    }
}
