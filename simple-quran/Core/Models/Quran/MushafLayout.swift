//
//  MushafLayout.swift
//  simple-quran
//

import Foundation

/// How the Quran is read: as a list of ayahs, or as Mushaf pages.
enum QuranReadingMode: String, CaseIterable, Sendable {
    case list
    case mushaf

    var titleKey: String {
        switch self {
        case .list:
            return "quran_reading_mode_list"
        case .mushaf:
            return "quran_reading_mode_mushaf"
        }
    }
}

/// Where surahs, ayahs and juz fall in the 604-page Madani Mushaf.
struct MushafLayout: Equatable, Sendable {
    struct AyahReference: Comparable, Sendable {
        let surah: Int
        let ayah: Int

        static func < (lhs: Self, rhs: Self) -> Bool {
            (lhs.surah, lhs.ayah) < (rhs.surah, rhs.ayah)
        }
    }

    static let surahCount = 114

    let pageCount: Int
    /// The first page of each surah, indexed from surah 1.
    let surahStartPages: [Int]
    /// The first ayah on each page, indexed from page 1.
    let pageStarts: [AyahReference]
    /// The first ayah of each juz, indexed from juz 1.
    let juzStarts: [AyahReference]

    func clampedPage(_ page: Int) -> Int {
        min(max(page, 1), pageCount)
    }

    func startPage(ofSurah surah: Int) -> Int {
        surahStartPages[min(max(surah, 1), surahStartPages.count) - 1]
    }

    /// The page an ayah is on: the last page starting at or before it.
    func page(forSurah surah: Int, ayah: Int) -> Int {
        let target = AyahReference(surah: surah, ayah: max(ayah, 1))
        let index = pageStarts.lastIndex { $0 <= target } ?? 0
        return index + 1
    }

    /// The surahs with text on `page`, in order.
    func surahs(onPage page: Int) -> [Int] {
        let page = clampedPage(page)
        let first = pageStarts[page - 1].surah
        guard page < pageCount else {
            return Array(first...Self.surahCount)
        }

        let next = pageStarts[page]
        let last = next.ayah == 1 ? next.surah - 1 : next.surah
        return Array(first...max(first, last))
    }

    /// The first page of each two-page spread. As in a printed Madani
    /// Mushaf, odd pages sit on the right and the even page after on the
    /// left, starting with pages 1 and 2.
    var spreadStarts: [Int] {
        Array(stride(from: 1, through: pageCount, by: 2))
    }

    func spreadStart(forPage page: Int) -> Int {
        let page = clampedPage(page)
        return page.isMultiple(of: 2) ? page - 1 : page
    }

    /// The pages of the spread `page` is in, right page first.
    func spreadPages(forPage page: Int) -> [Int] {
        let start = spreadStart(forPage: page)
        return start < pageCount ? [start, start + 1] : [start]
    }

    /// The juz the page starts in.
    func juz(onPage page: Int) -> Int {
        let start = pageStarts[clampedPage(page) - 1]
        return (juzStarts.lastIndex { $0 <= start } ?? 0) + 1
    }
}

// MARK: - Decoding

/// The layout of `Mushaf.bundle/pages.json`. Ayah references are
/// `[surah, ayah]` pairs.
struct MushafLayoutDTO: Decodable {
    let pageCount: Int
    let surahStartPages: [Int]
    let pageStarts: [[Int]]
    let juzStarts: [[Int]]

    enum DecodingError: Error {
        case invalid
    }

    func layout() throws -> MushafLayout {
        let pages = try pageStarts.map(Self.reference)
        let juz = try juzStarts.map(Self.reference)

        guard pageCount > 0,
              pages.count == pageCount,
              surahStartPages.count == MushafLayout.surahCount,
              !juz.isEmpty else {
            throw DecodingError.invalid
        }

        return MushafLayout(
            pageCount: pageCount,
            surahStartPages: surahStartPages,
            pageStarts: pages,
            juzStarts: juz
        )
    }

    private static func reference(_ pair: [Int]) throws -> MushafLayout.AyahReference {
        guard pair.count == 2 else { throw DecodingError.invalid }
        return MushafLayout.AyahReference(surah: pair[0], ayah: pair[1])
    }
}
