//
//  MushafGoldTests.swift
//  hidayah-app-tests
//

import UIKit
import XCTest
@testable import hidayah_app

final class MushafGoldTests: XCTestCase {
    func test_mushafGold_should_loadWithLightAndDarkVariants() {
        // Arrange
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)

        // Act
        let colour = UIColor(named: "MushafGold")

        // Assert
        XCTAssertNotNil(colour)
        XCTAssertNotEqual(
            colour?.resolvedColor(with: light),
            colour?.resolvedColor(with: dark)
        )
    }
}
