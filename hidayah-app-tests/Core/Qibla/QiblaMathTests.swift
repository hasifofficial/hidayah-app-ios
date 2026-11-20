//
//  QiblaMathTests.swift
//  hidayah-app-tests
//

import CoreLocation
import XCTest
@testable import hidayah_app

final class QiblaMathTests: XCTestCase {
    private let kualaLumpur = CLLocationCoordinate2D(latitude: 3.1390, longitude: 101.6869)
    private let london = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
    private let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

    func test_bearing_should_matchKnownQiblaDirections() {
        // Arrange
        let expected: [(CLLocationCoordinate2D, Double)] = [
            (kualaLumpur, 292.6),
            (london, 119.0),
            (newYork, 58.5)
        ]

        // Act
        let bearings = expected.map { QiblaMath.bearing(from: $0.0) }

        // Assert
        for (bearing, (_, value)) in zip(bearings, expected) {
            XCTAssertEqual(bearing, value, accuracy: 0.5)
        }
    }

    func test_distance_should_matchKnownDistanceToMakkah() {
        // Arrange
        let origin = kualaLumpur

        // Act
        let kilometers = QiblaMath.distance(from: origin) / 1000

        // Assert
        XCTAssertEqual(kilometers, 7_000, accuracy: 30)
        XCTAssertEqual(QiblaMath.distance(from: QiblaMath.kaaba), 0, accuracy: 0.001)
    }

    func test_normalized_should_wrapIntoFullTurn() {
        // Arrange
        let angles: [Double] = [-90, 360, 725, 0]

        // Act
        let wrapped = angles.map(QiblaMath.normalized)

        // Assert
        XCTAssertEqual(wrapped, [270, 0, 5, 0])
    }

    func test_signedDelta_should_takeShortestTurn() {
        // Arrange
        let pairs: [(Double, Double)] = [(350, 10), (10, 350), (0, 180), (90, 45)]

        // Act
        let deltas = pairs.map { QiblaMath.signedDelta(from: $0.0, to: $0.1) }

        // Assert
        XCTAssertEqual(deltas, [20, -20, -180, -45])
    }
}
