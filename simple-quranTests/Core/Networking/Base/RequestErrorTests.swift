//
//  RequestErrorTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class RequestErrorTests: XCTestCase {
    func test_requestErrorMessage_should_localiseEveryCase() {
        // Arrange
        let expected: [(RequestError, String)] = [
            (.decode, "Data cannot be parsed. Please try again later."),
            (.invalidURL, "The URL is invalid, Make sure the URL is correct and try again later."),
            (.noResponse, "No response from server. Please try again later."),
            (.unauthorized, "You don't have access to view this resource"),
            (.unexpectedStatusCode, "Unexpected response from server. Please try again later."),
            (.unknown, "Something went wrong. Please try again later.")
        ]

        // Act
        let messages = expected.map { $0.0.message }

        // Assert
        XCTAssertEqual(messages, expected.map(\.1))
    }
}
