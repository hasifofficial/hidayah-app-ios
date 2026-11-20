//
//  MushafLayoutTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class MushafLayoutTests: XCTestCase {
    private func bundledLayout() throws -> MushafLayout {
        try BundleMushafLoader().layout()
    }

    func test_startPage_should_matchPrintedMushaf() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let pages = [1, 2, 18, 36, 67, 114].map(layout.startPage(ofSurah:))

        // Assert
        XCTAssertEqual(pages, [1, 2, 293, 440, 562, 604])
    }

    func test_page_should_findPageOfAyah() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let ayatulKursi = layout.page(forSurah: 2, ayah: 255)
        let kahfTen = layout.page(forSurah: 18, ayah: 10)
        let lastAyah = layout.page(forSurah: 114, ayah: 6)

        // Assert
        XCTAssertEqual(ayatulKursi, 42)
        XCTAssertEqual(kahfTen, 294)
        XCTAssertEqual(lastAyah, 604)
    }

    func test_surahs_should_listEverySurahOnPage() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let fatiha = layout.surahs(onPage: 1)
        let baqara = layout.surahs(onPage: 3)
        let kahfStart = layout.surahs(onPage: 293)
        let lastPage = layout.surahs(onPage: 604)

        // Assert
        XCTAssertEqual(fatiha, [1])
        XCTAssertEqual(baqara, [2])
        XCTAssertEqual(kahfStart, [17, 18])
        XCTAssertEqual(lastPage, [112, 113, 114])
    }

    func test_juz_should_followJuzStarts() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let juz = [1, 21, 22, 293, 582, 604].map(layout.juz(onPage:))

        // Assert
        XCTAssertEqual(juz, [1, 1, 2, 15, 30, 30])
    }

    func test_spreads_should_pairOddPageWithFollowingEvenPage() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let starts = layout.spreadStarts
        let kahf = layout.spreadPages(forPage: 293)
        let kahfLeft = layout.spreadStart(forPage: 294)
        let last = layout.spreadPages(forPage: 604)

        // Assert
        XCTAssertEqual(starts.count, 302)
        XCTAssertEqual(starts.first, 1)
        XCTAssertEqual(kahf, [293, 294])
        XCTAssertEqual(kahfLeft, 293)
        XCTAssertEqual(last, [603, 604])
    }

    func test_spreadPages_should_showLonePage_when_pageCountIsOdd() {
        // Arrange
        let fixture = MushafFixtures.layout()
        let layout = MushafLayout(
            pageCount: 3,
            surahStartPages: fixture.surahStartPages,
            pageStarts: Array(fixture.pageStarts.prefix(3)),
            juzStarts: fixture.juzStarts
        )

        // Act
        let starts = layout.spreadStarts
        let last = layout.spreadPages(forPage: 3)

        // Assert
        XCTAssertEqual(starts, [1, 3])
        XCTAssertEqual(last, [3])
    }

    func test_layout_should_clampOutOfRangeInput() {
        // Arrange
        let layout = MushafFixtures.layout()

        // Act
        let low = layout.clampedPage(0)
        let high = layout.clampedPage(99)
        let surah = layout.startPage(ofSurah: 500)
        let beforeFirst = layout.page(forSurah: 0, ayah: 0)

        // Assert
        XCTAssertEqual(low, 1)
        XCTAssertEqual(high, 4)
        XCTAssertEqual(surah, 4)
        XCTAssertEqual(beforeFirst, 1)
        XCTAssertEqual(layout.surahs(onPage: 99), Array(3...114))
    }

    func test_decoding_should_rejectInconsistentFile() {
        // Arrange
        let dto = MushafLayoutDTO(
            pageCount: 2,
            surahStartPages: [1],
            pageStarts: [[1, 1]],
            juzStarts: [[1, 1]]
        )

        // Act & Assert
        XCTAssertThrowsError(try dto.layout())
    }

    func test_decoding_should_rejectMalformedReference() {
        // Arrange
        let dto = MushafLayoutDTO(
            pageCount: 1,
            surahStartPages: Array(repeating: 1, count: 114),
            pageStarts: [[1]],
            juzStarts: [[1, 1]]
        )

        // Act & Assert
        XCTAssertThrowsError(try dto.layout())
    }

    // MARK: Hizb

    func test_hizbQuarterStarts_should_coverWholeQuran() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let quarters = layout.hizbQuarterStarts

        // Assert
        XCTAssertEqual(quarters.count, 240)
        XCTAssertEqual(quarters.first, MushafLayout.AyahReference(surah: 1, ayah: 1))
        XCTAssertEqual(quarters, quarters.sorted())
    }

    func test_hizbQuarterStarts_should_agreeWithJuzStarts() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let everyEighth = stride(from: 0, to: 240, by: 8).map { layout.hizbQuarterStarts[$0] }

        // Assert
        XCTAssertEqual(everyEighth, layout.juzStarts)
    }

    func test_hizb_should_followQuarterStarts() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let hizb = [1, 2, 11, 22, 42, 604].map { layout.hizb(onPage: $0) }

        // Assert
        XCTAssertEqual(hizb, [1, 1, 1, 3, 5, 60])
    }

    func test_quarterStarts_should_listQuartersBeginningOnPage() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let quarters = [1, 2, 5, 11, 22, 604].map { layout.quarterStarts(onPage: $0) }

        // Assert
        XCTAssertEqual(quarters, [[1], [], [2], [5], [9], []])
    }

    func test_hizb_should_beNil_when_layoutHasNoHizbData() {
        // Arrange
        let layout = MushafFixtures.layout(withQuarters: false)

        // Act
        let hizb = layout.hizb(onPage: 2)
        let quarters = layout.quarterStarts(onPage: 1)

        // Assert
        XCTAssertNil(hizb)
        XCTAssertEqual(quarters, [])
    }

    func test_startPageOfJuz_should_matchPrintedMushaf() throws {
        // Arrange
        let layout = try bundledLayout()

        // Act
        let pages = [0, 1, 2, 30, 31].map(layout.startPage(ofJuz:))

        // Assert
        XCTAssertEqual(pages, [1, 1, 22, 582, 582])
    }

    func test_readingMode_should_exposeTitleKeys() {
        // Arrange
        let modes = QuranReadingMode.allCases

        // Act
        let keys = modes.map(\.titleKey)

        // Assert
        XCTAssertEqual(keys, ["quran_reading_mode_list", "quran_reading_mode_mushaf"])
    }
}
