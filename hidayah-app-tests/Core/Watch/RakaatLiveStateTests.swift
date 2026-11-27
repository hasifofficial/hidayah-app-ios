//
//  RakaatLiveStateTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class RakaatLiveStateTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 2_000_000)

    private func makeState(updatedAt: Date) -> RakaatLiveState {
        RakaatLiveState(
            sessionID: UUID(),
            prayer: .maghrib,
            completedRakaat: 2,
            sujoodInCurrentRakaat: 1,
            isActive: true,
            sequence: 7,
            events: [.rakaatCompleted(2), .tashahhud(isFinal: false)],
            updatedAt: updatedAt
        )
    }

    func test_statePayload_should_roundTrip() {
        // Arrange
        let state = makeState(updatedAt: now)

        // Act
        let payload = WatchMessage.payload(for: state)
        let decoded = payload.flatMap(WatchMessage.rakaatState(from:))

        // Assert
        XCTAssertEqual(decoded, state)
        XCTAssertNil(payload.flatMap(WatchMessage.snapshot(from:)))
    }

    func test_commandPayload_should_roundTrip() {
        // Arrange
        let command = RakaatCommand(sessionID: UUID(), action: .decrement)

        // Act
        let payload = WatchMessage.payload(for: command)
        let decoded = payload.flatMap(WatchMessage.rakaatCommand(from:))

        // Assert
        XCTAssertEqual(decoded, command)
        XCTAssertNil(payload.flatMap(WatchMessage.completion(from:)))
    }

    func test_isStale_should_beTrue_when_notUpdatedForTwentyMinutes() {
        // Arrange
        let fresh = makeState(updatedAt: now - 60)
        let old = makeState(updatedAt: now - RakaatLiveState.staleInterval - 1)

        // Act
        let result = (fresh.isStale(now: now), old.isStale(now: now))

        // Assert
        XCTAssertFalse(result.0)
        XCTAssertTrue(result.1)
    }

    func test_cue_should_pickMostImportantEvent() {
        // Arrange
        let sujoodOnly: [RakaatEvent] = [.sujoodCounted(1)]
        let rakaat: [RakaatEvent] = [.sujoodCounted(2), .rakaatCompleted(1)]
        let tashahhud: [RakaatEvent] = [.rakaatCompleted(2), .tashahhud(isFinal: false)]
        let complete: [RakaatEvent] = [.rakaatCompleted(4), .tashahhud(isFinal: true), .prayerCompleted]

        // Act
        let cues = [sujoodOnly, rakaat, tashahhud, complete].map(RakaatCue.cue(for:))

        // Assert
        XCTAssertEqual(cues, [nil, .rakaat, .tashahhud, .complete])
    }
}
