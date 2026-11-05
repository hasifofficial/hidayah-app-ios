//
//  MushafLibraryTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class MushafLibraryTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("MushafLibraryTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
        try super.tearDownWithError()
    }

    // MARK: Failures

    func test_layout_should_throwMissingResource_when_bundleIsMissing() {
        // Arrange
        let loader = BundleMushafLoader(directory: nil)

        // Act & Assert
        XCTAssertThrowsError(try loader.layout()) { error in
            XCTAssertEqual(error as? MushafLoadError, .missingResource)
        }
    }

    func test_layout_should_throwCorrupt_when_jsonIsInvalid() throws {
        // Arrange
        try Data("{ nope".utf8).write(to: directory.appendingPathComponent("pages.json"))
        let loader = BundleMushafLoader(directory: directory)

        // Act & Assert
        XCTAssertThrowsError(try loader.layout()) { error in
            XCTAssertEqual(error as? MushafLoadError, .corrupt)
        }
    }

    func test_pageImage_should_returnNil_when_pageIsMissing() {
        // Arrange
        let loader = BundleMushafLoader(directory: directory)

        // Act
        let image = loader.pageImage(1, maxPixelWidth: 400)

        // Assert
        XCTAssertNil(image)
    }

    func test_imageName_should_padPageNumber() {
        // Arrange
        let pages = [1, 42, 604]

        // Act
        let names = pages.map(BundleMushafLoader.imageName(for:))

        // Assert
        XCTAssertEqual(names, ["page001.png", "page042.png", "page604.png"])
    }

    // MARK: Bundled content

    func test_bundledLayout_should_coverEveryPageInOrder() throws {
        // Arrange
        let loader = BundleMushafLoader()

        // Act
        let layout = try loader.layout()

        // Assert
        XCTAssertEqual(layout.pageCount, 604)
        XCTAssertEqual(layout.juzStarts.count, 30)
        XCTAssertEqual(layout.surahStartPages, layout.surahStartPages.sorted())
        XCTAssertEqual(layout.pageStarts, layout.pageStarts.sorted())
    }

    func test_bundledPages_should_haveAnImageForEveryPage() throws {
        // Arrange
        let directory = try XCTUnwrap(Bundle.main.url(forResource: "Mushaf", withExtension: "bundle"))

        // Act
        let missing = (1...604).filter {
            !FileManager.default.fileExists(
                atPath: directory.appendingPathComponent(BundleMushafLoader.imageName(for: $0)).path
            )
        }

        // Assert
        XCTAssertTrue(missing.isEmpty, "\(missing)")
    }

    func test_pageImage_should_decodeAtRequestedWidth() throws {
        // Arrange
        let loader = BundleMushafLoader()

        // Act
        let image = try XCTUnwrap(loader.pageImage(3, maxPixelWidth: 480))

        // Assert
        XCTAssertEqual(image.width, 480, accuracy: 2)
        // The trimmed page: 1880×3064 of the 1920×3106 original.
        XCTAssertEqual(Double(image.height) / Double(image.width), 3064.0 / 1880.0, accuracy: 0.01)
    }

    func test_pageImage_should_notUpscale() throws {
        // Arrange
        let loader = BundleMushafLoader()

        // Act
        let image = try XCTUnwrap(loader.pageImage(1, maxPixelWidth: 5000))

        // Assert
        XCTAssertEqual(image.width, 1880, accuracy: 1)
    }

    func test_pageImage_should_keepAllTextInsideTrim() throws {
        // Arrange
        let trim = BundleMushafLoader.trim

        // Act
        let left = trim.left * 1920
        let right = 1920 - trim.right * 1920
        let top = trim.top * 3106
        let bottom = 3106 - trim.bottom * 3106

        // Assert: the text bounds measured across all 604 pages.
        XCTAssertLessThanOrEqual(left, 26)
        XCTAssertGreaterThanOrEqual(right, 1894)
        XCTAssertLessThanOrEqual(top, 14)
        XCTAssertGreaterThanOrEqual(bottom, 3066)
    }
}
