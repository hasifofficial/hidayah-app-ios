//
//  QiblaViewModelTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

@MainActor
final class FakeQiblaSensor: QiblaSensing {
    var authorization: QiblaAuthorization
    var isHeadingAvailable: Bool
    var onEvent: ((QiblaSensorEvent) -> Void)?
    private(set) var requestCount = 0
    private(set) var startCount = 0
    private(set) var stopCount = 0

    init(authorization: QiblaAuthorization = .authorized, isHeadingAvailable: Bool = true) {
        self.authorization = authorization
        self.isHeadingAvailable = isHeadingAvailable
    }

    func requestAuthorization() { requestCount += 1 }
    func start() { startCount += 1 }
    func stop() { stopCount += 1 }

    func send(_ event: QiblaSensorEvent) { onEvent?(event) }
}

@MainActor
final class QiblaViewModelTests: XCTestCase {
    /// Kuala Lumpur, where the Qibla is about 292.6°.
    private let kualaLumpur = QiblaSensorEvent.location(latitude: 3.1390, longitude: 101.6869)

    private func makeViewModel(
        sensor: FakeQiblaSensor = FakeQiblaSensor(),
        steps: @escaping (Double) -> Void = { _ in },
        aligned: @escaping () -> Void = {}
    ) -> QiblaViewModel {
        QiblaViewModel(sensor: sensor, haptics: QiblaHaptics(step: steps, aligned: aligned))
    }

    func test_onAppear_should_requestPermission_when_notDetermined() {
        // Arrange
        let sensor = FakeQiblaSensor(authorization: .notDetermined)
        let vm = makeViewModel(sensor: sensor)

        // Act
        vm.onAppear()

        // Assert
        XCTAssertEqual(sensor.requestCount, 1)
        XCTAssertEqual(vm.status, .needsPermission)
    }

    func test_status_should_followAuthorizationAndSensorData() {
        // Arrange
        let sensor = FakeQiblaSensor(authorization: .notDetermined)
        let vm = makeViewModel(sensor: sensor)
        vm.onAppear()

        // Act
        sensor.send(.authorization(.denied))
        let denied = vm.status
        sensor.send(.authorization(.authorized))
        let locating = vm.status
        sensor.send(kualaLumpur)
        sensor.send(.heading(degrees: 0, accuracy: 5))
        let ready = vm.status

        // Assert
        XCTAssertEqual(denied, .denied)
        XCTAssertEqual(locating, .locating)
        XCTAssertEqual(ready, .ready)
    }

    func test_status_should_beHeadingUnavailable_when_deviceHasNoCompass() {
        // Arrange
        let sensor = FakeQiblaSensor(isHeadingAvailable: false)

        // Act
        let vm = makeViewModel(sensor: sensor)

        // Assert
        XCTAssertEqual(vm.status, .headingUnavailable)
    }

    func test_offset_should_tellWhichWayToTurn() {
        // Arrange
        let vm = makeViewModel()
        vm.handle(kualaLumpur)

        // Act
        vm.handle(.heading(degrees: 270, accuracy: 5))
        let right = (vm.turnDirection, vm.offsetText, vm.guidanceText)
        vm.handle(.heading(degrees: 320, accuracy: 5))
        let left = (vm.turnDirection, vm.offsetText, vm.guidanceText)

        // Assert
        XCTAssertEqual(right.0, .right)
        XCTAssertEqual(right.1, "23°")
        XCTAssertEqual(right.2, "to your right")
        XCTAssertEqual(left.0, .left)
        XCTAssertEqual(left.1, "27°")
        XCTAssertEqual(left.2, "to your left")
    }

    func test_isAligned_should_useHysteresisAndPlayHapticOnce() {
        // Arrange
        var alignedCount = 0
        let vm = makeViewModel(aligned: { alignedCount += 1 })
        vm.handle(kualaLumpur)

        // Act
        vm.handle(.heading(degrees: 280, accuracy: 5))  // 12.6° off
        let before = vm.isAligned
        vm.handle(.heading(degrees: 290, accuracy: 5))  // 2.6° off
        let inside = vm.isAligned
        vm.handle(.heading(degrees: 286, accuracy: 5))  // 6.6° off, still held
        let held = vm.isAligned
        vm.handle(.heading(degrees: 283, accuracy: 5))  // 9.6° off, released
        let released = vm.isAligned

        // Assert
        XCTAssertFalse(before)
        XCTAssertTrue(inside)
        XCTAssertTrue(held)
        XCTAssertFalse(released)
        XCTAssertEqual(alignedCount, 1)
        XCTAssertEqual(vm.turnDirection, .right)
    }

    func test_stepHaptic_should_fireWhenCrossingTenDegreeSteps() {
        // Arrange
        var closeness: [Double] = []
        let vm = makeViewModel(steps: { closeness.append($0) })
        vm.handle(kualaLumpur)

        // Act
        vm.handle(.heading(degrees: 200, accuracy: 5))  // 92.6° off: first reading
        vm.handle(.heading(degrees: 202, accuracy: 5))  // 90.6°, same step
        vm.handle(.heading(degrees: 250, accuracy: 5))  // 42.6°, new step

        // Assert
        XCTAssertEqual(closeness.count, 1)
        XCTAssertEqual(closeness.first ?? 0, 1 - 42.6 / 180, accuracy: 0.01)
    }

    func test_arrowRotation_should_takeShortWayAcrossNorth() {
        // Arrange
        let vm = makeViewModel()
        vm.handle(kualaLumpur)
        vm.handle(.heading(degrees: 112, accuracy: 5))  // offset ≈ -179.4

        // Act
        let start = vm.arrowRotation
        vm.handle(.heading(degrees: 114, accuracy: 5))  // offset ≈ 178.6

        // Assert
        XCTAssertEqual(vm.arrowRotation - start, -2, accuracy: 0.01)
    }

    func test_needsCalibration_should_followHeadingAccuracy() {
        // Arrange
        let vm = makeViewModel()
        vm.handle(kualaLumpur)

        // Act
        vm.handle(.heading(degrees: 0, accuracy: -1))
        let invalid = vm.needsCalibration
        vm.handle(.heading(degrees: 0, accuracy: 40))
        let poor = vm.needsCalibration
        vm.handle(.heading(degrees: 0, accuracy: 10))
        let good = vm.needsCalibration

        // Assert
        XCTAssertTrue(invalid)
        XCTAssertTrue(poor)
        XCTAssertFalse(good)
    }

    func test_onDisappear_should_stopSensor() {
        // Arrange
        let sensor = FakeQiblaSensor()
        let vm = makeViewModel(sensor: sensor)
        vm.onAppear()

        // Act
        vm.onDisappear()

        // Assert
        XCTAssertEqual(sensor.startCount, 1)
        XCTAssertEqual(sensor.stopCount, 1)
    }
}
