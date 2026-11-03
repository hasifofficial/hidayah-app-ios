//
//  ViewHostTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest

@MainActor
private final class Counter: ObservableObject {
    @Published var taps = 0
}

private struct CounterView: View {
    @ObservedObject var counter: Counter

    var body: some View {
        VStack {
            Text("Taps \(counter.taps)")
            Button("Increment") {
                counter.taps += 1
            }
        }
    }
}

@MainActor
final class ViewHostTests: XCTestCase {
    func test_tap_should_runButtonAction() {
        // Arrange
        let counter = Counter()
        let host = ViewHost(CounterView(counter: counter))

        // Act
        host.tap("Increment")

        // Assert
        XCTAssertEqual(counter.taps, 1)
        XCTAssertTrue(host.contains("Taps 1"))
    }
}
