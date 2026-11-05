//
//  SurahDetailViewModelTests.swift
//  simple-quranTests
//

import AVFoundation
import XCTest
@testable import simple_quran

@MainActor
final class SurahDetailViewModelTests: XCTestCase {
    private var store: HidayahStore!

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        store = makeInMemoryStore()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        store = nil
        super.tearDown()
    }

    private func makeViewModel(
        surahNo: Int? = 18,
        bookmarkedAyah: Int? = nil,
        scrollToSpecificAyah: Bool = false
    ) -> SurahDetailViewModel {
        let vm = SurahDetailViewModel(
            surahService: makeStubbedSurahService(),
            bookmarkedAyah: bookmarkedAyah,
            scrollToSpecificAyah: scrollToSpecificAyah,
            store: store
        )
        vm.selectedSurahNo = surahNo
        return vm
    }

    private func routeDefaults(
        surahNo: Int = 18,
        detail: String = VMFixtures.detailJSON(),
        recitation: String = "ar.alafasy",
        translation: String = "en.asad"
    ) {
        VMFixtures.route([
            VMFixtures.editionPath: (200, VMFixtures.editionJSON()),
            VMFixtures.detailPath(
                surahNo: surahNo,
                recitation: recitation,
                translation: translation
            ): (200, detail)
        ])
    }

    private func loadedViewModel(
        bookmarkedAyah: Int? = nil,
        scrollToSpecificAyah: Bool = false
    ) async -> SurahDetailViewModel {
        routeDefaults()
        let vm = makeViewModel(
            bookmarkedAyah: bookmarkedAyah,
            scrollToSpecificAyah: scrollToSpecificAyah
        )
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty && !vm.translationItems.isEmpty }
        return vm
    }

    private func ayah(
        _ number: Int,
        audioURL: URL? = nil
    ) -> SurahDetailAyah {
        SurahDetailAyah(
            id: number,
            numberInSurah: number,
            arabic: "عربي \(number)",
            translation: "Translation \(number)",
            audioURL: audioURL,
            translationIsRTL: false
        )
    }

    // MARK: - Loading

    func test_loadIfNeeded_should_requestDefaultEditionsForSelectedSurah() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        _ = await loadedViewModel()

        // Assert
        XCTAssertEqual(
            Set(VMFixtures.requestedPaths()),
            [VMFixtures.editionPath, VMFixtures.detailPath(surahNo: 18)]
        )
    }

    func test_loadIfNeeded_should_populateTitleDescriptionAndNames() async {
        // Arrange
        routeDefaults()
        let vm = makeViewModel()
        var titles: [String] = []
        vm.onTitleChange = { titles.append($0) }

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty }

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.title, "Al-Kahf")
        XCTAssertEqual(vm.surahName, "Al-Kahf")
        XCTAssertEqual(titles, ["Al-Kahf"])
        XCTAssertEqual(vm.reciterName, "Alafasy")
        XCTAssertEqual(vm.translationName, "English")
        XCTAssertNil(vm.selectedTranslationValue)
        XCTAssertEqual(
            vm.descriptionText,
            "Al-Kahf means The Cave and consists of 3 verses. Its compilation order is 18. It was revealed in Makkah."
        )
    }

    func test_loadIfNeeded_should_describeMedinanSurahAsMadinah() async {
        // Arrange
        routeDefaults(detail: VMFixtures.detailJSON(revelationType: "Medinan"))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty }

        // Assert
        XCTAssertTrue(vm.descriptionText.hasSuffix("revealed in Madinah."))
    }

    func test_loadIfNeeded_should_stripBismillahFromFirstAyahOfNonFatihaSurah() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel()

        // Assert
        XCTAssertEqual(vm.ayahs.map(\.numberInSurah), [1, 2, 3])
        XCTAssertEqual(vm.ayahs[0].arabic, "ٱلْحَمْدُ لِلَّهِ")
        XCTAssertEqual(vm.ayahs[1].arabic, "قَيِّمًا")
        XCTAssertEqual(vm.ayahs[0].translation, "All praise is due to God")
        XCTAssertEqual(vm.ayahs[0].audioURL?.absoluteString, "https://cdn.example.com/1.mp3")
        XCTAssertNil(vm.ayahs[2].audioURL)
        XCTAssertFalse(vm.ayahs[0].translationIsRTL)
    }

    func test_loadIfNeeded_should_keepBismillahForAlFatiha() async {
        // Arrange
        let arabic = [VMFixtures.ayah(1, text: VMFixtures.bismillah + "x")]
        let translation = [VMFixtures.ayah(1, text: "In the name of God")]
        routeDefaults(
            surahNo: 1,
            detail: VMFixtures.detailJSON(
                surahNo: 1,
                englishName: "Al-Faatiha",
                arabic: arabic,
                translation: translation
            )
        )
        let vm = makeViewModel(surahNo: 1)

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty }

        // Assert
        XCTAssertEqual(vm.ayahs.first?.arabic, VMFixtures.bismillah + "x")
    }

    func test_loadIfNeeded_should_skipAyahsMissingTextOrTranslation() async {
        // Arrange
        let arabic = [
            VMFixtures.ayah(1, text: "a"),
            VMFixtures.ayah(2, text: nil),
            VMFixtures.ayah(3, text: "c"),
            VMFixtures.ayah(4, text: "d")
        ]
        let translation = [
            VMFixtures.ayah(1, text: "A"),
            VMFixtures.ayah(2, text: "B"),
            VMFixtures.ayah(3, text: nil)
        ]
        routeDefaults(
            detail: VMFixtures.detailJSON(arabic: arabic, translation: translation)
        )
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty }

        // Assert
        XCTAssertEqual(vm.ayahs.map(\.numberInSurah), [1])
    }

    func test_loadIfNeeded_should_markRightToLeftTranslations() async {
        // Arrange
        VMFixtures.saveSelected(VMFixtures.urdu, key: .selectedTranslation)
        routeDefaults(
            detail: VMFixtures.detailJSON(translationEdition: VMFixtures.urdu),
            translation: "ur.jalandhry"
        )
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty }

        // Assert
        XCTAssertTrue(vm.ayahs.allSatisfy(\.translationIsRTL))
        XCTAssertEqual(vm.translationName, Constants.getLanguageFromCode(code: "ur"))
        XCTAssertEqual(vm.selectedTranslationValue, "ur.jalandhry")
    }

    func test_loadIfNeeded_should_useStoredEditionsForRequestAndNames() async {
        // Arrange
        VMFixtures.saveSelected(VMFixtures.husary, key: .selectedRecitation)
        VMFixtures.saveSelected(VMFixtures.indonesian, key: .selectedTranslation)
        routeDefaults(recitation: "ar.husary", translation: "id.indonesian")
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty && !vm.translationItems.isEmpty }

        // Assert
        XCTAssertTrue(
            VMFixtures.requestedPaths().contains(
                VMFixtures.detailPath(
                    surahNo: 18,
                    recitation: "ar.husary",
                    translation: "id.indonesian"
                )
            )
        )
        XCTAssertEqual(vm.reciterName, "Husary")
        XCTAssertEqual(vm.selectedRecitationValue, "ar.husary")
        XCTAssertEqual(vm.translationName, Constants.getLanguageFromCode(code: "id"))
        XCTAssertEqual(vm.selectedTranslationValue, "id.indonesian")
    }

    func test_loadIfNeeded_should_hydrateBookmarkedAyahsForThisSurahOnly() async {
        // Arrange
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 2))
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 1))

        // Act
        let vm = await loadedViewModel()

        // Assert
        XCTAssertEqual(vm.bookmarkedAyahs, [2])
    }

    func test_loadIfNeeded_should_notReloadOnceLoaded() async {
        // Arrange
        let vm = await loadedViewModel()
        let requestCount = StubURLProtocol.requests.count

        // Act
        vm.loadIfNeeded()
        try? await Task.sleep(for: .milliseconds(100))

        // Assert
        XCTAssertEqual(StubURLProtocol.requests.count, requestCount)
    }

    func test_loadIfNeeded_should_doNothingWithoutSelectedSurah() async {
        // Arrange
        VMFixtures.route([VMFixtures.editionPath: (200, VMFixtures.editionJSON())])
        let vm = makeViewModel(surahNo: nil)

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.translationItems.isEmpty }

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(VMFixtures.requestedPaths(), [VMFixtures.editionPath])
    }

    func test_loadIfNeeded_should_showErrorWhenDetailRequestFails() async {
        // Arrange
        VMFixtures.route([VMFixtures.editionPath: (200, VMFixtures.editionJSON())])
        let vm = makeViewModel()
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        vm.loadIfNeeded()
        await waitUntil { vm.errorMessage != nil }

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.errorMessage, RequestError.unexpectedStatusCode.message)
        XCTAssertEqual(errors, [RequestError.unexpectedStatusCode.message])
        XCTAssertTrue(vm.ayahs.isEmpty)
    }

    func test_loadIfNeeded_should_showErrorWhenEditionRequestFails() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.detailPath(surahNo: 18): (200, VMFixtures.detailJSON())
        ])
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { vm.errorMessage != nil && !vm.ayahs.isEmpty }

        // Assert
        XCTAssertEqual(vm.errorMessage, RequestError.unexpectedStatusCode.message)
        XCTAssertTrue(vm.recitationItems.isEmpty)
    }

    func test_loadIfNeeded_should_ignoreIncompleteDetailPayload() async {
        // Arrange
        routeDefaults(detail: VMFixtures.detailJSON(englishName: nil))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil {
            !vm.isLoading && !vm.translationItems.isEmpty && StubURLProtocol.requests.count == 2
        }
        try? await Task.sleep(for: .milliseconds(100))

        // Assert
        XCTAssertTrue(vm.ayahs.isEmpty)
        XCTAssertEqual(vm.title, "")
        XCTAssertNil(vm.errorMessage)
    }

    func test_loadIfNeeded_should_ignoreEditionsWithNullData() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.editionPath: (200, VMFixtures.nullDataJSON),
            VMFixtures.detailPath(surahNo: 18): (200, VMFixtures.detailJSON())
        ])
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.ayahs.isEmpty && StubURLProtocol.requests.count == 2 }
        try? await Task.sleep(for: .milliseconds(100))

        // Assert
        XCTAssertTrue(vm.recitationItems.isEmpty)
        XCTAssertTrue(vm.translationItems.isEmpty)
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - Editions

    func test_loadIfNeeded_should_buildFilteredEditionSelectors() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel()

        // Assert
        XCTAssertEqual(vm.recitationItems.map(\.value), ["ar.alafasy", "ar.husary"])
        XCTAssertEqual(vm.recitationItems.map(\.title), ["Alafasy", "Husary"])
        XCTAssertEqual(vm.translationItems.map(\.value), ["en.asad", "id.indonesian"])
        XCTAssertEqual(
            vm.translationItems.first?.title,
            "\(Constants.getLanguageFromCode(code: "en")) - Asad"
        )
    }

    func test_selectRecitation_should_persistAndReloadWithNewRecitation() async {
        // Arrange
        let vm = await loadedViewModel()
        VMFixtures.route([
            VMFixtures.detailPath(surahNo: 18, recitation: "ar.husary"): (200, VMFixtures.detailJSON())
        ])
        StubURLProtocol.requests = []

        // Act
        vm.selectRecitation(vm.recitationItems[1])
        await waitUntil { !StubURLProtocol.requests.isEmpty && !vm.isLoading }

        // Assert
        let stored: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        XCTAssertEqual(stored?.identifier, "ar.husary")
        XCTAssertEqual(vm.reciterName, "Husary")
        XCTAssertEqual(vm.selectedRecitationValue, "ar.husary")
        XCTAssertEqual(
            VMFixtures.requestedPaths(),
            [VMFixtures.detailPath(surahNo: 18, recitation: "ar.husary")]
        )
        XCTAssertNil(vm.errorMessage)
    }

    func test_selectTranslation_should_persistAndReloadWithNewTranslation() async {
        // Arrange
        let vm = await loadedViewModel()
        VMFixtures.route([
            VMFixtures.detailPath(surahNo: 18, translation: "id.indonesian"): (200, VMFixtures.detailJSON())
        ])
        StubURLProtocol.requests = []

        // Act
        vm.selectTranslation(vm.translationItems[1])
        await waitUntil { !StubURLProtocol.requests.isEmpty && !vm.isLoading }

        // Assert
        let stored: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        XCTAssertEqual(stored?.identifier, "id.indonesian")
        XCTAssertEqual(vm.translationName, Constants.getLanguageFromCode(code: "id"))
        XCTAssertEqual(vm.selectedTranslationValue, "id.indonesian")
        XCTAssertEqual(
            VMFixtures.requestedPaths(),
            [VMFixtures.detailPath(surahNo: 18, translation: "id.indonesian")]
        )
    }

    func test_selectRecitation_should_fallBackToDefaultNamesForUnnamedEdition() {
        // Arrange
        let vm = makeViewModel(surahNo: nil)
        let unnamed = EditionResponse(
            identifier: "x.unnamed", language: nil, name: nil, englishName: nil,
            format: .audio, type: "versebyverse", direction: nil
        )
        let item = ItemSelector(title: "", value: "x.unnamed", item: unnamed)

        // Act
        vm.selectRecitation(item)
        vm.selectTranslation(item)

        // Assert
        XCTAssertEqual(vm.reciterName, "Alafasy")
        XCTAssertEqual(vm.translationName, Constants.getLanguageFromCode(code: ""))
        XCTAssertEqual(vm.selectedRecitationValue, "x.unnamed")
        XCTAssertEqual(vm.selectedTranslationValue, "x.unnamed")
    }

    func test_selectRecitation_should_ignoreItemsWithoutEdition() {
        // Arrange
        let vm = makeViewModel()
        let item = ItemSelector(title: "x", value: "x", item: nil)

        // Act
        vm.selectRecitation(item)
        vm.selectTranslation(item)

        // Assert
        XCTAssertNil(Storage.load(key: .selectedRecitation))
        XCTAssertNil(Storage.load(key: .selectedTranslation))
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    // MARK: - Scroll to ayah

    func test_loadIfNeeded_should_scrollToBookmarkedAyahWhenRequested() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel(bookmarkedAyah: 2, scrollToSpecificAyah: true)

        // Assert
        XCTAssertEqual(vm.scrollToAyah, 2)
        XCTAssertNil(vm.errorMessage)
    }

    func test_loadIfNeeded_should_notScrollWhenScrollNotRequested() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel(bookmarkedAyah: 2, scrollToSpecificAyah: false)

        // Assert
        XCTAssertNil(vm.scrollToAyah)
    }

    func test_loadIfNeeded_should_showOutOfRangeErrorForAyahBeyondSurah() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel(bookmarkedAyah: 9, scrollToSpecificAyah: true)

        // Assert
        XCTAssertNil(vm.scrollToAyah)
        XCTAssertEqual(
            vm.errorMessage,
            "Invalid verse number 9. This surah only has 3 verses"
        )
    }

    func test_loadIfNeeded_should_showGenericErrorForAyahZero() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel(bookmarkedAyah: 0, scrollToSpecificAyah: true)

        // Assert
        XCTAssertNil(vm.scrollToAyah)
        XCTAssertEqual(vm.errorMessage, "Something went wrong. Please try again later.")
    }

    // MARK: - Bookmarks

    func test_toggleBookmark_should_addThenRemoveAyahBookmark() async {
        // Arrange
        let vm = await loadedViewModel()
        let target = vm.ayahs[2]

        // Act
        vm.toggleBookmark(ayah: target)
        let afterAdd = vm.bookmarkedAyahs
        vm.toggleBookmark(ayah: target)

        // Assert
        XCTAssertEqual(afterAdd, [3])
        XCTAssertTrue(vm.bookmarkedAyahs.isEmpty)
        XCTAssertTrue(store.bookmarks().isEmpty)
    }

    func test_toggleBookmark_should_exposeOnlySelectedSurahAyahs() {
        // Arrange
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 1))
        let vm = makeViewModel()

        // Act
        vm.toggleBookmark(ayah: ayah(5))

        // Assert
        XCTAssertEqual(vm.bookmarkedAyahs, [5])
        XCTAssertEqual(store.bookmarks().count, 2)
    }

    func test_toggleBookmark_should_doNothingWithoutSelectedSurah() {
        // Arrange
        let vm = makeViewModel(surahNo: nil)

        // Act
        vm.toggleBookmark(ayah: ayah(1))

        // Assert
        XCTAssertTrue(vm.bookmarkedAyahs.isEmpty)
        XCTAssertTrue(store.bookmarks().isEmpty)
    }

    // MARK: - Audio

    func test_toggleAudio_should_startPlayingAyahWithAudio() {
        // Arrange
        let vm = makeViewModel()
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ayah1.mp3")

        // Act
        vm.toggleAudio(ayah: ayah(1, audioURL: url))

        // Assert
        XCTAssertEqual(vm.playingAyahID, 1)
        XCTAssertEqual((vm.testAudioPlayer?.currentItem?.asset as? AVURLAsset)?.url, url)
    }

    func test_toggleAudio_should_stopWhenSameAyahToggledAgain() {
        // Arrange
        let vm = makeViewModel()
        let item = ayah(1, audioURL: URL(fileURLWithPath: "/tmp/ayah1.mp3"))
        vm.toggleAudio(ayah: item)

        // Act
        vm.toggleAudio(ayah: item)

        // Assert
        XCTAssertNil(vm.playingAyahID)
        XCTAssertEqual(vm.testAudioPlayer?.rate, 0)
    }

    func test_toggleAudio_should_switchToOtherAyah() {
        // Arrange
        let vm = makeViewModel()
        let secondURL = URL(fileURLWithPath: "/tmp/ayah2.mp3")
        vm.toggleAudio(ayah: ayah(1, audioURL: URL(fileURLWithPath: "/tmp/ayah1.mp3")))

        // Act
        vm.toggleAudio(ayah: ayah(2, audioURL: secondURL))

        // Assert
        XCTAssertEqual(vm.playingAyahID, 2)
        XCTAssertEqual((vm.testAudioPlayer?.currentItem?.asset as? AVURLAsset)?.url, secondURL)
    }

    func test_toggleAudio_should_stopPlaybackForAyahWithoutAudio() {
        // Arrange
        let vm = makeViewModel()
        vm.toggleAudio(ayah: ayah(1, audioURL: URL(fileURLWithPath: "/tmp/ayah1.mp3")))

        // Act
        vm.toggleAudio(ayah: ayah(2, audioURL: nil))

        // Assert
        XCTAssertNil(vm.playingAyahID)
    }

    func test_toggleAudio_should_clearPlayingAyahWhenItemFinishes() async {
        // Arrange
        let vm = makeViewModel()
        vm.toggleAudio(ayah: ayah(1, audioURL: URL(fileURLWithPath: "/tmp/ayah1.mp3")))
        let item = vm.testAudioPlayer?.currentItem

        // Act
        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: item)
        await waitUntil { vm.playingAyahID == nil }

        // Assert
        XCTAssertNotNil(item)
        XCTAssertNil(vm.playingAyahID)
    }

    func test_deinit_should_releaseViewModelWhilePlaying() {
        // Arrange
        var vm: SurahDetailViewModel? = makeViewModel()
        weak var weakVM = vm
        vm?.toggleAudio(ayah: ayah(1, audioURL: URL(fileURLWithPath: "/tmp/ayah1.mp3")))

        // Act
        vm = nil

        // Assert
        XCTAssertNil(weakVM)
    }

    // MARK: - Sharing

    func test_shareText_should_includeTranslationReferenceAndDeeplink() {
        // Arrange
        let vm = makeViewModel()

        // Act
        let text = vm.shareText(for: ayah(10))

        // Assert
        XCTAssertEqual(
            text,
            "عربي 10\nTranslation 10 [18:10]\n\nShared from Hidayah App\nhidayahapp://inAppDeeplink/quran/18/10"
        )
    }

    func test_shareText_should_returnArabicOnlyWithoutSelectedSurah() {
        // Arrange
        let vm = makeViewModel(surahNo: nil)

        // Act
        let text = vm.shareText(for: ayah(10))

        // Assert
        XCTAssertEqual(text, "عربي 10")
    }

    func test_reload_should_refetchDetail() async {
        // Arrange
        let vm = await loadedViewModel()
        StubURLProtocol.requests = []

        // Act
        vm.reload()
        await waitUntil { !StubURLProtocol.requests.isEmpty && !vm.isLoading }

        // Assert
        XCTAssertEqual(VMFixtures.requestedPaths(), [VMFixtures.detailPath(surahNo: 18)])
    }
}
