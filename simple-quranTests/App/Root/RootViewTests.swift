//
//  RootViewTests.swift
//  simple-quranTests
//

import SwiftUI
import UIKit
import XCTest
@testable import simple_quran

@MainActor
private final class SizeClassModel: ObservableObject {
    @Published var sizeClass: UserInterfaceSizeClass

    init(_ sizeClass: UserInterfaceSizeClass) {
        self.sizeClass = sizeClass
    }
}

private struct RootHarness: View {
    let root: RootView
    @ObservedObject var model: SizeClassModel

    var body: some View {
        root.environment(\.horizontalSizeClass, model.sizeClass)
    }
}

@MainActor
final class RootViewTests: ViewsTestCase {
    private var router: AppRouter!
    private var taskManager: TaskManager!
    private var sharedBookmarks: [SurahBookmark] = []

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        ViewsFixtures.route()
        SurahCatalog.shared.store(ViewsFixtures.loadedCatalog().surahs)
        router = AppRouter()
        taskManager = ViewsFixtures.makeTaskManager()
        sharedBookmarks = []
    }

    override func tearDown() {
        // Undo bookmarks added to the shared store used by RootView.
        for bookmark in sharedBookmarks {
            HidayahStore.shared.toggleBookmark(bookmark)
        }
        super.tearDown()
    }

    private func addSharedBookmark(_ bookmark: SurahBookmark) {
        HidayahStore.shared.toggleBookmark(bookmark)
        sharedBookmarks.append(bookmark)
    }

    private func makeRoot() -> RootView {
        RootView(
            surahService: makeStubbedSurahService(),
            taskManager: taskManager,
            router: router
        )
    }

    private func makeHost(
        sizeClass: UserInterfaceSizeClass = .compact,
        size: CGSize = CGSize(width: 402, height: 2400)
    ) -> (ViewHost<RootHarness>, SizeClassModel) {
        let model = SizeClassModel(sizeClass)
        let host = sceneHost(RootHarness(root: makeRoot(), model: model), size: size)
        host.pump(0.4)
        return (host, model)
    }

    // MARK: Compact tabs



    func test_rootView_should_showQuranTabWithTabBar() {
        // Arrange
        let tabs = ["Al-Mathurat", "Tasbih", "Tracker", "Search"]

        // Act
        let (host, _) = makeHost()
        host.pump(until: { host.contains("All Surahs") })

        // Assert
        XCTAssertEqual(router.selectedTab, .quran)
        XCTAssertTrue(host.contains("All Surahs"))
        XCTAssertTrue(host.contains("Al-Kahf"))
        for tab in tabs {
            XCTAssertTrue(host.labels().contains { $0.hasPrefix(tab) }, "Missing tab \(tab)")
        }
    }

    func test_rootView_should_selectTabFromTabBar() {
        // Arrange
        let (host, _) = makeHost()

        // Act
        host.selectTabBarItem("Search")
        let afterSearch = router.selectedTab
        host.selectTabBarItem("Tasbih")

        // Assert
        XCTAssertEqual(afterSearch, .search)
        XCTAssertEqual(router.selectedTab, .tasbih)
    }

    func test_rootView_should_pushSurahDetailWhenSurahTapped() {
        // Arrange
        let (host, _) = makeHost()
        host.pump(until: { host.contains("Al-Kahf") })

        // Act
        host.tap("18, Al-Kahf")
        host.pump(until: { host.contains("Arabic 1") })

        // Assert
        XCTAssertEqual(
            router.quranPath,
            [.surahDetail(surahNumber: 18, title: "Al-Kahf", bookmarkedAyah: nil)]
        )
        XCTAssertTrue(host.contains("Arabic 1"))
    }

    func test_rootView_should_openBookmarksAndPushBookmarkedAyah() {
        // Arrange
        addSharedBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 255))
        let (host, _) = makeHost()
        host.pump(until: { host.contains("All Surahs") })

        // Act
        host.tap("Bookmarks")
        host.pump(until: { host.contains("Verse 255") })
        host.tap("Verse 255")
        host.pump(0.3)

        // Assert
        XCTAssertEqual(
            router.quranPath,
            [
                .bookmarkList,
                .surahDetail(surahNumber: 2, title: "Al-Baqara", bookmarkedAyah: 255)
            ]
        )
    }

    func test_rootView_should_openSettingsFromEveryTabToolbar() {
        for tab in AppTab.allCases {
            // Arrange
            router.selectTab(tab)
            router.settingsPresented = false
            let (host, _) = makeHost()

            // Act
            host.tap("More")
            host.pump(0.2)

            // Assert
            XCTAssertTrue(router.settingsPresented, "Settings not opened from \(tab)")
            host.tearDown()
        }
    }

    func test_rootView_should_openSettingsFromBookmarkList() {
        // Arrange
        router.quranPath = [.bookmarkList]
        let (host, _) = makeHost()

        // Act
        host.tapLast("More")
        host.pump(0.2)

        // Assert
        XCTAssertTrue(router.settingsPresented)
    }

    private let destinationChecks: [(AppRoute, String)] = [
        (.surahDetail(surahNumber: 18, title: "Al-Kahf", bookmarkedAyah: nil), "Arabic 1"),
        (.bookmarkList, "You have no bookmarks"),
        (.trackerCalendar, "Tracker Calendar"),
        (.trackerAchievements, "Achievements"),
        (.trackerLevels, "How to earn points"),
        (.trackerDay(dayKey: "2026-11-03"), "Daily Progress")
    ]

    func test_rootView_should_renderEveryQuranDestination() {
        // Arrange
        let (host, _) = makeHost()
        var missing: [String] = []

        for (route, text) in destinationChecks {
            // Act
            router.quranPath = [route]
            if !host.pump(until: { host.contains(text) }) {
                missing.append(text)
            }
            router.quranPath = []
            host.pump(0.4)
        }

        // Assert
        XCTAssertEqual(missing, [])
    }

    func test_rootView_should_renderEveryTrackerDestination() {
        // Arrange
        router.selectTab(.tracker)
        let (host, _) = makeHost()
        var missing: [String] = []

        for (route, text) in destinationChecks {
            // Act
            router.trackerPath = [route]
            if !host.pump(until: { host.contains(text) }) {
                missing.append(text)
            }
            router.trackerPath = []
            host.pump(0.4)
        }

        // Assert
        XCTAssertEqual(missing, [])
    }

    func test_rootView_should_renderSearchDestinations() {
        // Arrange
        router.selectTab(.search)
        let (host, _) = makeHost()

        // Act
        router.searchPath = [.bookmarkList]
        let shown = host.pump(until: { host.contains("You have no bookmarks") })

        // Assert
        XCTAssertTrue(shown)
    }

    func test_rootView_should_pushTrackerScreensFromToolbar() {
        // Arrange
        router.selectTab(.tracker)
        let (host, _) = makeHost()

        // Act
        host.tap("Calendar")
        let afterCalendar = router.trackerPath
        router.trackerPath = []
        host.pump(0.3)
        host.tap(host.trophyLabel)
        let afterAchievements = router.trackerPath

        // Assert
        XCTAssertEqual(afterCalendar, [.trackerCalendar])
        XCTAssertEqual(afterAchievements, [.trackerAchievements])
    }

    func test_rootView_should_pushLevelsFromTrackerSummary() {
        // Arrange
        router.selectTab(.tracker)
        let (host, _) = makeHost()

        // Act
        host.tap(", Level")

        // Assert
        XCTAssertEqual(router.trackerPath, [.trackerLevels])
    }

    func test_rootView_should_pushDayDetailFromCalendar() {
        // Arrange
        router.selectTab(.tracker)
        let (host, _) = makeHost()
        router.trackerPath = [.trackerCalendar]
        host.pump(until: { host.contains("1 November 2026") })

        // Act
        host.tap("1 November 2026")
        host.pump(0.5)

        // Assert
        XCTAssertEqual(router.trackerPath.count, 2)
        XCTAssertEqual(router.trackerPath.first, .trackerCalendar)
        if case .trackerDay(let dayKey)? = router.trackerPath.last {
            XCTAssertTrue(dayKey.hasSuffix("11-01"), dayKey)
        } else {
            XCTFail("Expected a day detail route")
        }
    }

    func test_rootView_should_pushDayDetailFromCalendarOnQuranStack() {
        // Arrange
        let (host, _) = makeHost()
        router.quranPath = [.trackerCalendar]
        host.pump(until: { host.contains("1 November 2026") })

        // Act
        host.tap("1 November 2026")
        host.pump(0.3)

        // Assert
        // The shared destination builder always appends day details to the
        // tracker stack, whichever stack showed the calendar.
        XCTAssertEqual(router.trackerPath.count, 1)
    }

    // MARK: Search tab

    func test_rootView_should_searchAndPushSurahDetail() {
        // Arrange
        router.selectTab(.search)
        let (host, _) = makeHost()
        host.pump(0.3)

        // Act
        host.search("kahf")
        host.pump(until: { host.contains("110 verses") })
        host.tap("110 verses")
        host.pump(0.3)

        // Assert
        XCTAssertTrue(host.contains("Search"))
        XCTAssertEqual(
            router.searchPath,
            [.surahDetail(surahNumber: 18, title: "Al-Kahf", bookmarkedAyah: nil)]
        )
    }

    func test_rootView_should_pushBookmarkedAyahFromSearch() {
        // Arrange
        addSharedBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        router.selectTab(.search)
        let (host, _) = makeHost()
        host.pump(0.3)
        host.search("kahf")
        host.pump(until: { host.contains("Verse 10") })

        // Act
        host.tap("Verse 10")
        host.pump(0.3)
        let pushed = router.searchPath
        router.searchPath = []
        host.pump(0.3)

        // Assert
        XCTAssertEqual(
            pushed,
            [.surahDetail(surahNumber: 18, title: "Al-Kahf", bookmarkedAyah: 10)]
        )
        XCTAssertTrue(router.searchPath.isEmpty)
    }

    // MARK: Alerts and settings sheet

    func test_rootView_should_showErrorAlertAndClearItOnOK() {
        // Arrange
        let (host, _) = makeHost()

        // Act
        router.errorMessage = "Network unavailable"
        host.pump(0.6)
        let shown = host.contains("Network unavailable")
        host.tapAlertButton("OK")

        // Assert
        XCTAssertTrue(shown)
        XCTAssertNil(router.errorMessage)
    }

    func test_rootView_should_reportListErrorsThroughRouter() {
        for tab in [AppTab.quran, .search] {
            // Arrange
            SurahCatalog.shared.store([])
            ViewsFixtures.route(list: nil)
            router = AppRouter()
            router.selectTab(tab)
            if tab == .quran {
                router.quranPath = [.bookmarkList]
            }

            // Act
            let (host, _) = makeHost()
            host.pump(until: { self.router.errorMessage != nil })

            // Assert
            XCTAssertEqual(router.errorMessage, ViewsFixtures.serverErrorMessage, "\(tab)")
            host.tearDown()
        }
        SurahCatalog.shared.store(ViewsFixtures.loadedCatalog().surahs)
    }

    func test_settingsSheet_should_showSettingsAndCloseButton() {
        // Arrange
        let (host, _) = makeHost()
        router.settingsPresented = true
        host.pump(0.8)
        host.pump(until: { host.contains("Al-Kahf Reminder") })
        let shown = host.contains("Settings")

        // Act
        host.tapLast("Close")
        host.pump(0.8)

        // Assert
        XCTAssertTrue(shown)
        XCTAssertFalse(router.settingsPresented)
    }

    func test_settingsSheet_should_pushWidgetGuide() {
        // Arrange
        let (host, _) = makeHost()
        router.settingsPresented = true
        host.pump(0.8)
        host.pump(until: { host.contains("Widget Guide") })

        // Act
        host.tapLast("Widget Guide")
        host.pump(until: { host.contains("Choose a widget") })

        // Assert
        XCTAssertTrue(host.contains("How to Add a Widget"))
    }

    func test_settingsSheet_should_pushTrackerSettingsAndManageCategories() {
        // Arrange
        let (host, _) = makeHost()
        router.settingsPresented = true
        host.pump(0.8)
        host.pump(until: { host.contains("Tracker Settings") })

        // Act
        host.tapLast("Tracker Settings")
        host.pump(until: { host.contains("Manage Categories") })
        let trackerSettingsShown = host.contains("Reset Today's Progress")
        host.tapLast("Manage Categories")
        host.pump(0.6)

        // Assert
        XCTAssertTrue(trackerSettingsShown)
        XCTAssertTrue(host.contains("Custom Categories") || host.contains("You have no custom categories"))
    }

    func test_settingsSheet_should_resetTodayAndReturnToSettings() {
        // Arrange
        taskManager.toggleTaskCompletion(task: taskManager.tasks[0])
        let (host, _) = makeHost()
        router.settingsPresented = true
        host.pump(0.8)
        host.pump(until: { host.contains("Tracker Settings") })
        host.tapLast("Tracker Settings")
        host.pump(until: { host.contains("Reset Today's Progress") })

        // Act
        host.tapLast("Reset Today's Progress")
        host.pump(until: { host.contains("Are you sure you want to reset today's progress?") })
        host.tapAlertButton("Reset")
        host.pump(0.8)

        // Assert
        XCTAssertFalse(taskManager.tasks.contains(where: \.isCompleted))
        XCTAssertTrue(host.contains("Widget Guide"))
    }

    func test_settingsSheet_should_resetAllAndReturnToSettings() {
        // Arrange
        taskManager.addCustomCategory(name: "Study", icon: "book")
        let (host, _) = makeHost()
        router.settingsPresented = true
        host.pump(0.8)
        host.pump(until: { host.contains("Tracker Settings") })
        host.tapLast("Tracker Settings")
        host.pump(until: { host.contains("Reset All") })

        // Act
        host.tapLast("Reset All")
        host.pump(until: { host.contains("Reset all will restore everything") })
        host.tapAlertButton("Reset")
        host.pump(0.8)

        // Assert
        XCTAssertTrue(taskManager.customCategories.isEmpty)
        XCTAssertTrue(host.contains("Widget Guide"))
    }

    func test_settingsSheet_should_showEditionErrorAlert() {
        // Arrange
        ViewsFixtures.route(editions: nil)
        let (host, _) = makeHost()
        router.settingsPresented = true
        host.pump(0.8)

        // Act
        let shown = host.pump(until: { host.contains(ViewsFixtures.serverErrorMessage) })
        host.tapAlertButton("OK")
        host.pump(until: { !host.contains(ViewsFixtures.serverErrorMessage) })

        // Assert
        XCTAssertTrue(shown)
        XCTAssertFalse(host.contains(ViewsFixtures.serverErrorMessage))
        XCTAssertTrue(router.settingsPresented)
    }

    // MARK: Split view

    func test_rootView_should_showSidebarInRegularWidth() {
        // Arrange
        let size = CGSize(width: 1024, height: 1366)

        // Act
        let (host, _) = makeHost(
            sizeClass: .regular,
            size: size
        )
        host.pump(0.5)

        // Assert
        XCTAssertTrue(host.contains("Hidayah"))
        for tab in ["Quran", "Al-Mathurat", "Tasbih", "Tracker", "Search"] {
            XCTAssertTrue(host.contains(tab), "Missing sidebar item \(tab)")
        }
    }

    func test_rootView_should_switchDetailFromSidebar() {
        // Arrange
        router.quranPath = [.bookmarkList]
        let (host, _) = makeHost(
            sizeClass: .regular,
            size: CGSize(width: 1024, height: 1366)
        )

        // Act
        host.selectListRow("Tracker")
        let afterTracker = router.selectedTab
        host.selectListRow("Tasbih")
        let afterTasbih = router.selectedTab
        host.selectListRow("Search")

        // Assert
        XCTAssertEqual(afterTracker, .tracker)
        XCTAssertEqual(afterTasbih, .tasbih)
        XCTAssertEqual(router.selectedTab, .search)
        XCTAssertEqual(router.savedQuranPath, [.bookmarkList])
    }

    func test_rootView_should_switchLayoutWhenSizeClassChanges() {
        // Arrange
        let (host, model) = makeHost(size: CGSize(width: 1024, height: 1366))
        let compactHasSidebarLogo = host.contains("Hidayah")

        // Act
        model.sizeClass = .regular
        host.pump(0.6)
        let regularHasSidebarLogo = host.contains("Hidayah")
        router.quranPath = [.bookmarkList]
        host.pump(0.4)

        // Assert
        XCTAssertFalse(compactHasSidebarLogo)
        XCTAssertTrue(regularHasSidebarLogo)
    }

    func test_rootView_should_configureTabBarIcons() {
        // Arrange
        let (host, _) = makeHost()

        // Act
        host.attachToScene()
        host.pump(0.6)
        let tabBar = host.firstView(of: UITabBar.self)

        // Assert
        XCTAssertEqual(tabBar?.items?.count, AppTab.allCases.count)
        XCTAssertNotNil(tabBar?.items?[1].image)
        XCTAssertNotNil(tabBar?.items?[1].selectedImage)
        XCTAssertNotNil(tabBar?.items?[2].image)
        XCTAssertEqual(tabBar?.items?[0].image?.renderingMode, .alwaysTemplate)
        host.tearDown()
    }

    func test_appTab_should_exposeTitlesAndIcons() {
        // Arrange
        let tabs = AppTab.allCases

        // Act
        let titles = tabs.map(\.title)
        let icons = tabs.map(\.icon)
        let selectedIcons = tabs.map(\.selectedIcon)

        // Assert
        XCTAssertEqual(titles, ["Quran", "Al-Mathurat", "Tasbih", "Tracker", "Search"])
        XCTAssertEqual(icons, ["book", "sun.horizon", "circle.grid.3x3", "checklist.unchecked", "magnifyingglass"])
        XCTAssertEqual(selectedIcons, ["book.fill", "sun.horizon.fill", "circle.grid.3x3.fill", "checklist.checked", "magnifyingglass"])
        XCTAssertEqual(tabs.map(\.id), [0, 1, 2, 3, 4])
        XCTAssertNil(AppTab.mathurat.assetIcon)
        XCTAssertEqual(AppTab.tasbih.assetIcon, "TasbihIcon")
        XCTAssertEqual(AppTab.tasbih.selectedAssetIcon, "TasbihIconFill")
        XCTAssertNil(AppTab.quran.assetIcon)
    }
}
