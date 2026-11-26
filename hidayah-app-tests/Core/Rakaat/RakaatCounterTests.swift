//
//  RakaatCounterTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class RakaatCounterTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_000_000)
    /// Just past the flicker gap. Settling at exactly the gap is not
    /// reliable once the times go through `Date` arithmetic.
    private let settleDelay = RakaatCounter.flickerGap + 0.05

    /// Feeds one sujood: near at `at`, far after `duration`, then settles it
    /// once the flicker gap has passed. Returns the time it settled.
    @discardableResult
    private func sujood(
        _ counter: inout RakaatCounter,
        at time: TimeInterval,
        duration: TimeInterval = 2,
        events: inout [RakaatEvent]
    ) -> TimeInterval {
        events += counter.proximityChanged(isNear: true, at: start + time)
        events += counter.proximityChanged(isNear: false, at: start + time + duration)
        let settled = time + duration + settleDelay
        events += counter.advance(to: start + settled)
        return settled
    }

    private func rakaat(
        _ counter: inout RakaatCounter,
        at time: TimeInterval,
        events: inout [RakaatEvent]
    ) -> TimeInterval {
        let first = sujood(&counter, at: time, events: &events)
        return sujood(&counter, at: first + 1, events: &events) + 5
    }

    func test_twoSujood_should_completeOneRakaat() {
        // Arrange
        var counter = RakaatCounter(prayer: .dhuhr)
        var events: [RakaatEvent] = []

        // Act
        sujood(&counter, at: 0, events: &events)
        let afterFirst = counter.completedRakaat
        sujood(&counter, at: 5, events: &events)

        // Assert
        XCTAssertEqual(afterFirst, 0)
        XCTAssertEqual(counter.completedRakaat, 1)
        XCTAssertEqual(counter.sujoodInCurrentRakaat, 0)
        XCTAssertEqual(events, [.sujoodCounted(1), .sujoodCounted(2), .rakaatCompleted(1)])
    }

    func test_shortNear_should_beIgnored() {
        // Arrange
        var counter = RakaatCounter(prayer: .fajr)
        var events: [RakaatEvent] = []

        // Act
        sujood(&counter, at: 0, duration: RakaatCounter.minimumSujoodDuration - 0.1, events: &events)

        // Assert
        XCTAssertEqual(events, [])
        XCTAssertEqual(counter.sujoodInCurrentRakaat, 0)
    }

    func test_flickerGap_should_mergeIntoOneSujood() {
        // Arrange
        var counter = RakaatCounter(prayer: .fajr)
        var events: [RakaatEvent] = []

        // Act
        events += counter.proximityChanged(isNear: true, at: start)
        events += counter.proximityChanged(isNear: false, at: start + 0.5)
        events += counter.proximityChanged(isNear: true, at: start + 0.7)
        events += counter.proximityChanged(isNear: false, at: start + 1.5)
        events += counter.advance(to: start + 1.5 + settleDelay)

        // Assert
        XCTAssertEqual(events, [.sujoodCounted(1)])
    }

    func test_advance_should_waitForFlickerGap() {
        // Arrange
        var counter = RakaatCounter(prayer: .fajr)
        _ = counter.proximityChanged(isNear: true, at: start)
        _ = counter.proximityChanged(isNear: false, at: start + 2)

        // Act
        let early = counter.advance(to: start + 2.1)
        let late = counter.advance(to: start + 2 + settleDelay)

        // Assert
        XCTAssertEqual(early, [])
        XCTAssertEqual(late, [.sujoodCounted(1)])
    }

    func test_nextNear_should_settlePendingSujood_when_advanceWasMissed() {
        // Arrange
        var counter = RakaatCounter(prayer: .fajr)
        _ = counter.proximityChanged(isNear: true, at: start)
        _ = counter.proximityChanged(isNear: false, at: start + 2)

        // Act
        let events = counter.proximityChanged(isNear: true, at: start + 4)

        // Assert
        XCTAssertEqual(events, [.sujoodCounted(1)])
        XCTAssertTrue(counter.isInSujood)
    }

    func test_fourRakaatPrayer_should_cueTashahhudAfterSecondAndLast() {
        // Arrange
        var counter = RakaatCounter(prayer: .dhuhr)
        var events: [RakaatEvent] = []

        // Act
        var time: TimeInterval = 0
        for _ in 0..<4 {
            time = rakaat(&counter, at: time, events: &events)
        }

        // Assert
        let cues = events.filter {
            if case .sujoodCounted = $0 { return false }
            return true
        }
        XCTAssertEqual(cues, [
            .rakaatCompleted(1),
            .rakaatCompleted(2), .tashahhud(isFinal: false),
            .rakaatCompleted(3),
            .rakaatCompleted(4), .tashahhud(isFinal: true), .prayerCompleted
        ])
        XCTAssertTrue(counter.isComplete)
    }

    func test_twoRakaatPrayer_should_cueTashahhudOnlyAtEnd() {
        // Arrange
        var counter = RakaatCounter(prayer: .fajr)
        var events: [RakaatEvent] = []

        // Act
        let time = rakaat(&counter, at: 0, events: &events)
        let firstRakaatEvents = events
        _ = rakaat(&counter, at: time, events: &events)

        // Assert
        XCTAssertFalse(firstRakaatEvents.contains(.tashahhud(isFinal: false)))
        XCTAssertEqual(Array(events.suffix(3)), [
            .rakaatCompleted(2), .tashahhud(isFinal: true), .prayerCompleted
        ])
    }

    func test_input_should_beIgnored_when_prayerIsComplete() {
        // Arrange
        var counter = RakaatCounter(prayer: .custom(rakaat: 1))
        var events: [RakaatEvent] = []
        let time = rakaat(&counter, at: 0, events: &events)

        // Act
        var after: [RakaatEvent] = []
        sujood(&counter, at: time, events: &after)
        after += counter.manualIncrement()

        // Assert
        XCTAssertEqual(after, [])
        XCTAssertEqual(counter.completedRakaat, 1)
    }

    func test_manualIncrement_should_completeRakaatWithCues() {
        // Arrange
        var counter = RakaatCounter(prayer: .maghrib)
        _ = counter.manualIncrement()

        // Act
        let events = counter.manualIncrement()

        // Assert
        XCTAssertEqual(events, [.rakaatCompleted(2), .tashahhud(isFinal: false)])
    }

    func test_manualDecrement_should_clearPartRakaatFirst_then_clampAtZero() {
        // Arrange
        var counter = RakaatCounter(prayer: .dhuhr)
        var events: [RakaatEvent] = []
        _ = counter.manualIncrement()
        sujood(&counter, at: 0, events: &events)

        // Act
        counter.manualDecrement()
        let afterFirst = (counter.completedRakaat, counter.sujoodInCurrentRakaat)
        counter.manualDecrement()
        counter.manualDecrement()

        // Assert
        XCTAssertEqual(afterFirst.0, 1)
        XCTAssertEqual(afterFirst.1, 0)
        XCTAssertEqual(counter.completedRakaat, 0)
    }

    func test_reset_should_clearCount() {
        // Arrange
        var counter = RakaatCounter(prayer: .isha)
        _ = counter.manualIncrement()
        _ = counter.proximityChanged(isNear: true, at: start)

        // Act
        counter.reset()

        // Assert
        XCTAssertEqual(counter.completedRakaat, 0)
        XCTAssertFalse(counter.isInSujood)
        XCTAssertEqual(counter.progress, 0)
    }
}
