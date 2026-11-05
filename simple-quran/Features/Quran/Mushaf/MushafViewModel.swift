//
//  MushafViewModel.swift
//  simple-quran
//

import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
final class MushafViewModel {
    private(set) var layout: MushafLayout?
    private(set) var loadError: MushafLoadError?
    /// The page on screen, bound to the pager's scroll position.
    var scrolledPage: Int?
    /// Pages holding at least one bookmarked ayah.
    private(set) var bookmarkedPages: Set<Int> = []

    @ObservationIgnored
    private let surahNumber: Int
    @ObservationIgnored
    private let ayahNumber: Int?
    @ObservationIgnored
    private let loader: MushafLoading
    @ObservationIgnored
    private let catalog: SurahCatalog
    @ObservationIgnored
    private let store: HidayahStore

    /// Decoded pages near the ones on screen. Each phone-width page is a few
    /// megabytes, so only a handful are kept: enough for a spread and its
    /// neighbours.
    @ObservationIgnored
    private let images: NSCache<NSNumber, CGImage> = {
        let cache = NSCache<NSNumber, CGImage>()
        cache.countLimit = 8
        return cache
    }()

    init(
        surahNumber: Int,
        ayahNumber: Int? = nil,
        loader: MushafLoading = BundleMushafLoader(),
        catalog: SurahCatalog = .shared,
        store: HidayahStore = .shared
    ) {
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.loader = loader
        self.catalog = catalog
        self.store = store
    }

    /// The page the reader opens on: the ayah's page when one was given,
    /// otherwise the surah's first page.
    var startPage: Int {
        guard let layout else { return 1 }
        if let ayahNumber, ayahNumber > 0 {
            return layout.page(forSurah: surahNumber, ayah: ayahNumber)
        }
        return layout.startPage(ofSurah: surahNumber)
    }

    var currentPage: Int {
        scrolledPage ?? startPage
    }

    func loadIfNeeded() {
        guard layout == nil else { return }

        do {
            layout = try loader.layout()
            loadError = nil
            scrolledPage = startPage
            refreshBookmarks()
        } catch {
            loadError = error as? MushafLoadError ?? .corrupt
        }
    }

    func retry() {
        loadError = nil
        loadIfNeeded()
    }

    // MARK: Bookmarks
    //
    // A page bookmark is an ayah bookmark on its first ayah, so it shows in
    // the Bookmarks list and opens on the same place in List mode.

    /// Re-reads bookmarks, which List mode may have changed.
    func refreshBookmarks() {
        guard let layout else { return }
        bookmarkedPages = Set(
            store.bookmarks().map {
                layout.page(forSurah: $0.surahNumber, ayah: $0.numberInSurah)
            }
        )
    }

    func isBookmarked(page: Int) -> Bool {
        bookmarkedPages.contains(page)
    }

    /// Bookmarks the page's first ayah, or clears every bookmark on the page
    /// when it already has one.
    func toggleBookmark(page: Int) {
        guard let layout else { return }
        let page = layout.clampedPage(page)
        let onPage = store.bookmarks().filter {
            layout.page(forSurah: $0.surahNumber, ayah: $0.numberInSurah) == page
        }

        if onPage.isEmpty {
            let start = layout.pageStarts[page - 1]
            store.toggleBookmark(
                SurahBookmark(surahNumber: start.surah, numberInSurah: start.ayah)
            )
            AppHaptics.success()
        } else {
            onPage.forEach { store.toggleBookmark($0) }
            AppHaptics.tap()
        }
        refreshBookmarks()
    }

    func surahs(onPage page: Int) -> [Int] {
        layout?.surahs(onPage: page) ?? [surahNumber]
    }

    func juz(onPage page: Int) -> Int {
        layout?.juz(onPage: page) ?? 1
    }

    func surahName(_ number: Int) -> String {
        catalog.surahs.first { $0.number == number }?.englishName
            ?? String(
                format: NSLocalizedString("quran_mushaf_surah_fallback", comment: ""),
                number
            )
    }

    /// "Page 3, Al-Baqara, Juz 1", with ", bookmarked" when it is.
    func accessibilityLabel(forPage page: Int) -> String {
        let label = String(
            format: NSLocalizedString("quran_mushaf_page_accessibility", comment: ""),
            page,
            surahs(onPage: page).map(surahName).joined(separator: ", "),
            juz(onPage: page)
        )
        guard isBookmarked(page: page) else { return label }
        return label + NSLocalizedString("quran_mushaf_bookmarked_suffix", comment: "")
    }

    /// The page decoded off the main actor, from the cache when it is still
    /// there.
    func image(forPage page: Int, maxPixelWidth: CGFloat) async -> CGImage? {
        let key = NSNumber(value: page)
        if let cached = images.object(forKey: key) {
            return cached
        }

        let loader = loader
        let image = await Task.detached(priority: .userInitiated) {
            loader.pageImage(page, maxPixelWidth: maxPixelWidth)
        }.value

        if let image {
            images.setObject(image, forKey: key)
        }
        return image
    }
}
