//
//  SettingViewTests.swift
//  simple-quranTests
//

import MessageUI
import SafariServices
import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class SettingsViewTests: ViewsTestCase {
    private var notifications: FakeNotificationCenter!

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        notifications = FakeNotificationCenter()
    }

    private func makeViewModel() -> SettingsViewModel {
        SettingsViewModel(
            surahService: makeStubbedSurahService(),
            scheduler: TrackerNotificationScheduler(center: notifications)
        )
    }

    private func makeHost(
        _ viewModel: SettingsViewModel,
        onOpenTrackerSettings: (() -> Void)? = nil,
        onOpenWidgetGuide: (() -> Void)? = nil
    ) -> ViewHost<some View> {
        sceneHost(
            NavigationStack {
                SettingsView(
                    viewModel: viewModel,
                    onOpenTrackerSettings: onOpenTrackerSettings,
                    onOpenWidgetGuide: onOpenWidgetGuide
                )
            }
        )
    }

    func test_settingsView_should_showEverySection() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()

        // Act
        let host = makeHost(viewModel)
        await waitUntil(timeout: 5) { !viewModel.recitationItems.isEmpty }
        host.pump()

        // Assert
        for text in [
            "Quran", "Recitation", "Alafasy", "Translation", "English",
            "Arabic Font Size", "Istiqamah Tracker", "Tracker Settings",
            "Widgets", "Widget Guide", "Notification", "Al-Kahf Reminder",
            "Istiqamah Reminders", "What’s New", "About Us", "Privacy Policy",
            "Terms & Condition", "Support", "Feedback", "Version "
        ] {
            XCTAssertTrue(host.contains(text), "Missing \(text)")
        }
    }

    func test_settingsView_should_openWhatsNew_when_rowTapped() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)
        await waitUntil(timeout: 5) { !viewModel.recitationItems.isEmpty }
        host.pump()

        // Act
        host.tap("What’s New")
        host.pump(until: { host.contains("A Fresh New Look") })

        // Assert
        XCTAssertTrue(host.contains("A Fresh New Look"))
        XCTAssertTrue(host.contains("Feature 1 of 5"))
    }

    func test_settingsView_should_chooseRecitationFromSheet() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)
        await waitUntil(timeout: 5) { !viewModel.recitationItems.isEmpty }

        // Act
        host.tap("Recitation")
        host.pump(0.6)
        let sheetShown = host.contains("Choose recitation")
        host.tap("Husary")
        host.pump(0.6)

        // Assert
        XCTAssertTrue(sheetShown)
        XCTAssertEqual(viewModel.selectedRecitationName, "Husary")
        XCTAssertTrue(host.contains("Husary"))
    }

    func test_settingsView_should_chooseTranslationFromSheet() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)
        await waitUntil(timeout: 5) { !viewModel.translationItems.isEmpty }

        // Act
        host.tap("Translation")
        host.pump(0.6)
        let sheetShown = host.contains("Choose translation")
        host.tap("Urdu - Jalandhry")
        host.pump(0.6)

        // Assert
        XCTAssertTrue(sheetShown)
        XCTAssertEqual(viewModel.selectedTranslationValue, "ur.jalandhry")
        XCTAssertEqual(viewModel.selectedTranslationName, "Urdu")
    }

    func test_settingsView_should_notOpenSelectionWithoutEditions() async {
        // Arrange
        ViewsFixtures.route(editions: nil)
        let viewModel = makeViewModel()
        var errors: [String] = []
        viewModel.onError = { errors.append($0) }
        let host = makeHost(viewModel)
        await waitUntil(timeout: 5) { !errors.isEmpty }

        // Act
        host.tap("Recitation")
        host.pump(0.4)

        // Assert
        XCTAssertNil(host.controller.presentedViewController)
        XCTAssertFalse(host.contains("Choose recitation"))
    }

    func test_settingsView_should_openReadingSettingsSheet() {
        // Arrange
        ViewsFixtures.route()
        let host = makeHost(makeViewModel())

        // Act
        host.tap("Arabic Font Size")
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Arabic Text Size"))
    }

    func test_settingsView_should_callNavigationHandlers() {
        // Arrange
        ViewsFixtures.route()
        var trackerOpened = 0
        var guideOpened = 0
        let host = makeHost(
            makeViewModel(),
            onOpenTrackerSettings: { trackerOpened += 1 },
            onOpenWidgetGuide: { guideOpened += 1 }
        )

        // Act
        host.tap("Tracker Settings")
        host.tap("Widget Guide")

        // Assert
        XCTAssertEqual(trackerOpened, 1)
        XCTAssertEqual(guideOpened, 1)
    }

    func test_settingsView_should_saveNotificationToggles() {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)

        // Act
        host.toggleSwitch(at: 0)
        host.toggleSwitch(at: 1)

        // Assert
        XCTAssertFalse(viewModel.allowKahfReminder)
        XCTAssertFalse(viewModel.allowTrackerCheerleader)
        XCTAssertEqual(Storage.load(key: .allowKahfReminder) as? Bool, false)
        XCTAssertEqual(Storage.load(key: .allowTrackerCheerleader) as? Bool, false)
        XCTAssertFalse(notifications.removed.isEmpty)
    }

    func test_settingsView_should_ignoreFeedbackWhenMailUnavailable() throws {
        // Arrange
        try XCTSkipIf(MFMailComposeViewController.canSendMail(), "Mail is configured")
        ViewsFixtures.route()
        let host = makeHost(makeViewModel())

        // Act
        host.tap("Feedback")
        host.pump(0.4)

        // Assert
        XCTAssertNil(host.controller.presentedViewController)
    }

    func test_settingsView_should_ignoreNavigationTapsWithoutHandlers() {
        // Arrange
        ViewsFixtures.route()
        let host = sceneHost(NavigationStack { SettingsView(viewModel: makeViewModel()) })

        // Act
        host.tap("Tracker Settings")
        host.tap("Widget Guide")

        // Assert
        XCTAssertNil(host.controller.presentedViewController)
        XCTAssertTrue(host.contains("Tracker Settings"))
    }
}
