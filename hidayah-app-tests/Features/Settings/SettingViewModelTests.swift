//
//  SettingViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var center: FakeNotificationCenter!

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        center = FakeNotificationCenter()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        center = nil
        super.tearDown()
    }

    private func makeViewModel() -> SettingsViewModel {
        SettingsViewModel(
            surahService: makeStubbedSurahService(),
            scheduler: TrackerNotificationScheduler(center: center)
        )
    }

    private func loadedViewModel() async -> SettingsViewModel {
        VMFixtures.route([
            VMFixtures.editionPath: (200, VMFixtures.editionJSON())
        ])
        let vm = makeViewModel()
        vm.loadEditionsIfNeeded()
        await waitUntil { !vm.translationItems.isEmpty }
        return vm
    }

    // MARK: - Init

    func test_init_should_useDefaultsWhenNothingStored() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = makeViewModel()

        // Assert
        XCTAssertEqual(vm.selectedRecitationName, "Alafasy")
        XCTAssertNil(vm.selectedRecitationValue)
        XCTAssertEqual(vm.selectedTranslationName, "English")
        XCTAssertNil(vm.selectedTranslationValue)
        XCTAssertTrue(vm.allowKahfReminder)
        XCTAssertTrue(vm.allowTrackerCheerleader)
    }

    func test_init_should_restoreStoredSelectionsAndToggles() {
        // Arrange
        VMFixtures.saveSelected(VMFixtures.husary, key: .selectedRecitation)
        VMFixtures.saveSelected(VMFixtures.indonesian, key: .selectedTranslation)
        Storage.save(.allowKahfReminder, false)
        Storage.save(.allowTrackerCheerleader, false)

        // Act
        let vm = makeViewModel()

        // Assert
        XCTAssertEqual(vm.selectedRecitationName, "Husary")
        XCTAssertEqual(vm.selectedRecitationValue, "ar.husary")
        XCTAssertEqual(vm.selectedTranslationName, Constants.getLanguageFromCode(code: "id"))
        XCTAssertEqual(vm.selectedTranslationValue, "id.indonesian")
        XCTAssertFalse(vm.allowKahfReminder)
        XCTAssertFalse(vm.allowTrackerCheerleader)
    }

    func test_versionText_should_includeBundleVersionAndBuild() {
        // Arrange
        let vm = makeViewModel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

        // Act
        let text = vm.versionText

        // Assert
        XCTAssertEqual(text, "Version \(version) (\(build))")
    }

    // MARK: - Editions

    func test_loadEditionsIfNeeded_should_buildRecitationItemsFromVerseByVerseArabicAudio() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel()

        // Assert
        XCTAssertEqual(vm.items(for: .recitation).map(\.value), ["ar.alafasy", "ar.husary"])
        XCTAssertEqual(vm.items(for: .recitation).map(\.title), ["Alafasy", "Husary"])
    }

    func test_loadEditionsIfNeeded_should_buildTranslationItemsWithLanguagePrefix() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel()

        // Assert
        let english = Constants.getLanguageFromCode(code: "en")
        let indonesian = Constants.getLanguageFromCode(code: "id")
        XCTAssertEqual(vm.items(for: .translation).map(\.value), ["en.asad", "id.indonesian"])
        XCTAssertEqual(
            vm.items(for: .translation).map(\.title),
            ["\(english) - Asad", "\(indonesian) - Bahasa Indonesia"]
        )
    }

    func test_loadEditionsIfNeeded_should_matchDefaultRecitationByName() async {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = await loadedViewModel()

        // Assert
        XCTAssertEqual(vm.selectedValue(for: .recitation), "ar.alafasy")
        XCTAssertNil(vm.selectedValue(for: .translation))
    }

    func test_loadEditionsIfNeeded_should_keepStoredRecitationValue() async {
        // Arrange
        VMFixtures.saveSelected(VMFixtures.husary, key: .selectedRecitation)

        // Act
        let vm = await loadedViewModel()

        // Assert
        XCTAssertEqual(vm.selectedValue(for: .recitation), "ar.husary")
    }

    func test_loadEditionsIfNeeded_should_requestOnlyOnce() async {
        // Arrange
        let vm = await loadedViewModel()

        // Act
        vm.loadEditionsIfNeeded()
        try? await Task.sleep(for: .milliseconds(100))

        // Assert
        XCTAssertEqual(VMFixtures.requestedPaths(), [VMFixtures.editionPath])
    }

    func test_loadEditions_should_reportErrorWhenRequestFails() async {
        // Arrange
        VMFixtures.route([VMFixtures.editionPath: (500, "{}")])
        let vm = makeViewModel()
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        vm.loadEditions()
        await waitUntil { !errors.isEmpty }

        // Assert
        XCTAssertEqual(errors, [RequestError.unexpectedStatusCode.message])
        XCTAssertTrue(vm.recitationItems.isEmpty)
    }

    func test_loadEditions_should_ignoreNullData() async {
        // Arrange
        VMFixtures.route([VMFixtures.editionPath: (200, VMFixtures.nullDataJSON)])
        let vm = makeViewModel()
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        vm.loadEditions()
        await waitUntil { !StubURLProtocol.requests.isEmpty }
        try? await Task.sleep(for: .milliseconds(200))

        // Assert
        XCTAssertTrue(errors.isEmpty)
        XCTAssertTrue(vm.recitationItems.isEmpty)
        XCTAssertTrue(vm.translationItems.isEmpty)
    }

    // MARK: - Selection

    func test_select_should_persistRecitationAndUpdateName() async {
        // Arrange
        let vm = await loadedViewModel()
        let husary = vm.items(for: .recitation)[1]

        // Act
        vm.select(husary, for: .recitation)

        // Assert
        let stored: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        XCTAssertEqual(stored?.identifier, "ar.husary")
        XCTAssertEqual(vm.selectedRecitationName, "Husary")
        XCTAssertEqual(vm.selectedValue(for: .recitation), "ar.husary")
    }

    func test_select_should_persistTranslationAndUpdateLanguageName() async {
        // Arrange
        let vm = await loadedViewModel()
        let indonesian = vm.items(for: .translation)[1]

        // Act
        vm.select(indonesian, for: .translation)

        // Assert
        let stored: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        XCTAssertEqual(stored?.identifier, "id.indonesian")
        XCTAssertEqual(vm.selectedTranslationName, Constants.getLanguageFromCode(code: "id"))
        XCTAssertEqual(vm.selectedValue(for: .translation), "id.indonesian")
    }

    func test_select_should_ignoreItemsWithoutEdition() {
        // Arrange
        let vm = makeViewModel()
        let item = ItemSelector(title: "Broken", value: "x", item: "not an edition")

        // Act
        vm.select(item, for: .recitation)
        vm.select(item, for: .translation)

        // Assert
        XCTAssertNil(Storage.load(key: .selectedRecitation))
        XCTAssertNil(Storage.load(key: .selectedTranslation))
        XCTAssertEqual(vm.selectedRecitationName, "Alafasy")
        XCTAssertEqual(vm.selectedTranslationName, "English")
    }

    func test_select_should_ignoreEditionsMissingRequiredNames() {
        // Arrange
        let vm = makeViewModel()
        let noName = EditionResponse(
            identifier: "x", language: nil, name: nil, englishName: nil,
            format: .audio, type: "versebyverse", direction: nil
        )
        let item = ItemSelector(title: "", value: "x", item: noName)

        // Act
        vm.select(item, for: .recitation)
        vm.select(item, for: .translation)

        // Assert
        XCTAssertNil(vm.selectedRecitationValue)
        XCTAssertNil(vm.selectedTranslationValue)
        XCTAssertNil(Storage.load(key: .selectedRecitation))
    }

    // MARK: - Toggles

    func test_setKahfReminder_should_persistValue() {
        // Arrange
        let vm = makeViewModel()

        // Act
        vm.setKahfReminder(false)

        // Assert
        XCTAssertFalse(vm.allowKahfReminder)
        XCTAssertEqual(Storage.load(key: .allowKahfReminder) as? Bool, false)
    }

    func test_setTrackerCheerleader_should_scheduleDailyCheerWhenEnabled() {
        // Arrange
        let vm = makeViewModel()

        // Act
        vm.setTrackerCheerleader(true)

        // Assert
        XCTAssertEqual(Storage.load(key: .allowTrackerCheerleader) as? Bool, true)
        XCTAssertEqual(
            center.scheduled.map(\.identifier),
            [NotificationIdentifier.trackerDailyCheer.rawValue]
        )
    }

    func test_setTrackerCheerleader_should_removeDailyCheerWhenDisabled() async {
        // Arrange
        let vm = makeViewModel()
        center.pending = [
            NotificationIdentifier.trackerDailyCheer.rawValue,
            NotificationIdentifier.trackerMilestonePrefix + "50"
        ]

        // Act
        vm.setTrackerCheerleader(false)
        await waitUntil { self.center.pending.isEmpty }

        // Assert
        XCTAssertFalse(vm.allowTrackerCheerleader)
        XCTAssertEqual(Storage.load(key: .allowTrackerCheerleader) as? Bool, false)
        XCTAssertTrue(center.scheduled.isEmpty)
        XCTAssertEqual(center.removed.first, [NotificationIdentifier.trackerDailyCheer.rawValue])
    }

    func test_settingsSelection_should_exposeLocalizedTitlesAndIDs() {
        // Arrange
        let selections: [SettingsSelection] = [.recitation, .translation]

        // Act
        let ids = selections.map(\.id)
        let titles = selections.map(\.title)

        // Assert
        XCTAssertEqual(ids, ["recitation", "translation"])
        XCTAssertFalse(titles.contains("surah_recitation_drawer_title"))
        XCTAssertFalse(titles.contains("surah_translation_drawer_title"))
        XCTAssertNotEqual(titles[0], titles[1])
    }
}
