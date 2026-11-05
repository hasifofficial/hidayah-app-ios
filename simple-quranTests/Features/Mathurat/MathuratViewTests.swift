//
//  MathuratViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class MathuratViewTests: ViewsTestCase {
    private var settingsOpened = 0

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    private func makeViewModel(
        loader: FakeMathuratLoader = FakeMathuratLoader(),
        clock: TestClock = MathuratFixtures.clock(morning: true)
    ) -> MathuratViewModel {
        MathuratViewModel(
            loader: loader,
            now: { clock.now },
            calendar: TrackerDayKey.calendar
        )
    }

    /// A phone-height window, so the list is taller than the screen and the
    /// read percentage starts at 0.
    private func makeHost(
        _ viewModel: MathuratViewModel,
        focus: FocusBox = FocusBox()
    ) -> ViewHost<some View> {
        let host = sceneHost(
            NavigationStack {
                MathuratView(
                    viewModel: viewModel,
                    focusOrder: Binding(
                        get: { focus.order },
                        set: { focus.order = $0 }
                    )
                ) { [weak self] in
                    self?.settingsOpened += 1
                }
            },
            size: CGSize(width: 402, height: 500)
        )
        host.pump(0.4)
        return host
    }

    /// Scrolls the reader to `fraction` of its scrollable height.
    private func scroll<Content: View>(_ host: ViewHost<Content>, to fraction: CGFloat) {
        guard let scrollView = host.firstView(of: UIScrollView.self) else {
            XCTFail("No scroll view")
            return
        }
        let maxOffset = scrollView.contentSize.height
            - scrollView.bounds.height
            + scrollView.adjustedContentInset.bottom
        let top = -scrollView.adjustedContentInset.top
        scrollView.setContentOffset(
            CGPoint(x: 0, y: top + (maxOffset - top) * fraction),
            animated: false
        )
        host.pump(0.4)
    }

    /// Holds the deep-linked entry the view reads and clears.
    final class FocusBox {
        var order: Int?

        init(order: Int? = nil) {
            self.order = order
        }
    }

    private var manyEntries: FakeMathuratLoader {
        FakeMathuratLoader(entries: (1...12).map { MathuratFixtures.entry(id: $0) })
    }

    func test_mathuratView_should_showMorningHeaderAndEntries() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        let host = makeHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Al-Mathurat Sughra · Morning dhikr"))
        XCTAssertTrue(host.contains("Morning"))
        XCTAssertTrue(host.contains("0% completed"))
        XCTAssertTrue(host.contains("Al-Ma'thurat is a collection of dhikr and wird"))
        XCTAssertTrue(host.contains("In the evening (usually recited after Asr prayer)"))
        XCTAssertFalse(host.contains("Reset"))
        XCTAssertFalse(host.contains("starts at"))
        XCTAssertTrue(host.contains("Al Fatihah (1-7)"))
        XCTAssertTrue(host.contains("Aku berlindung 13"))
        XCTAssertFalse(host.contains("Aku berlindung 14"))
    }

    func test_mathuratView_should_showEveningEntries_when_afterThreePM() {
        // Arrange
        let viewModel = makeViewModel(clock: MathuratFixtures.clock(morning: false))

        // Act
        let host = makeHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Al-Mathurat Sughra · Evening dhikr"))
        XCTAssertTrue(host.contains("Aku berlindung 14"))
        XCTAssertFalse(host.contains("Aku berlindung 13"))
    }

    func test_mathuratView_should_hideTranslation_when_preferenceIsOff() {
        // Arrange
        Storage.save(.quranShowTranslation, false)
        let viewModel = makeViewModel()

        // Act
        let host = makeHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Al Fatihah (1-7)"))
        XCTAssertFalse(host.contains("Aku berlindung 1"))
    }

    func test_mathuratView_should_countEntry_when_counterIsTapped() {
        // Arrange
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)

        // Act
        host.tap("Count Dhikr 3")
        host.tap("Count Dhikr 3")

        // Assert
        let counter = host.elements().first {
            $0.accessibilityLabel == "Count Dhikr 3"
        }
        XCTAssertEqual(viewModel.count(for: viewModel.entries[2]), 2)
        XCTAssertEqual(counter?.accessibilityValue, "2 of 3")
    }

    func test_mathuratView_should_keepShowingCount_when_entryIsDone() {
        // Arrange
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)

        // Act
        host.tap("Count Dhikr 1")

        // Assert
        let counter = host.elements().first {
            $0.accessibilityLabel == "Count Dhikr 1"
        }
        XCTAssertTrue(viewModel.isComplete(viewModel.entries[0]))
        XCTAssertEqual(counter?.accessibilityValue, "1 of 1")
    }

    func test_mathuratView_should_resetCount_when_doneEntryIsTappedAgain() {
        // Arrange
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)
        host.tap("Count Dhikr 1")

        // Act
        host.tap("Count Dhikr 1")

        // Assert
        let counter = host.elements().first {
            $0.accessibilityLabel == "Count Dhikr 1"
        }
        XCTAssertEqual(viewModel.count(for: viewModel.entries[0]), 0)
        XCTAssertEqual(counter?.accessibilityValue, "0 of 1")
    }

    func test_mathuratView_should_showShareButtonForEachEntry() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        let host = makeHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Share Dhikr 1"))
        XCTAssertTrue(host.contains("Share Al Fatihah (1-7)"))
    }

    func test_mathuratView_should_scrollToEntry_when_deepLinked() {
        // Arrange
        let viewModel = makeViewModel(loader: manyEntries)
        let focus = FocusBox(order: 10)

        // Act
        let host = makeHost(viewModel, focus: focus)
        host.pump(1.0)

        // Assert
        let offset = host.firstView(of: UIScrollView.self)?.contentOffset.y ?? 0
        XCTAssertNil(focus.order)
        XCTAssertGreaterThan(offset, 200)
    }

    func test_mathuratView_should_scrollByOrder_when_deepLinked() {
        // Arrange
        let entries = (1...12).map { MathuratFixtures.entry(id: 100 + $0, order: $0) }
        let viewModel = makeViewModel(loader: FakeMathuratLoader(entries: entries))
        let focus = FocusBox(order: 10)

        // Act
        let host = makeHost(viewModel, focus: focus)
        host.pump(1.0)

        // Assert
        let offset = host.firstView(of: UIScrollView.self)?.contentOffset.y ?? 0
        XCTAssertNil(focus.order)
        XCTAssertGreaterThan(offset, 200)
    }

    func test_mathuratView_should_stayAtTop_when_deepLinkedEntryIsNotInSession() {
        // Arrange
        let viewModel = makeViewModel()
        let focus = FocusBox(order: 14)

        // Act
        let host = makeHost(viewModel, focus: focus)
        host.pump(1.0)

        // Assert
        let scrollView = host.firstView(of: UIScrollView.self)
        let top = -(scrollView?.adjustedContentInset.top ?? 0)
        XCTAssertNil(focus.order)
        XCTAssertEqual(scrollView?.contentOffset.y ?? 0, top, accuracy: 1)
    }

    func test_mathuratView_should_nameCounterAfterPassage_when_entryHasTitle() {
        // Arrange
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)

        // Act
        host.tap("Count Al Fatihah (1-7)")

        // Assert
        XCTAssertEqual(viewModel.count(for: viewModel.entries[1]), 1)
    }

    func test_mathuratView_should_showHundredPercent_when_scrolledToEnd() {
        // Arrange
        let viewModel = makeViewModel(loader: manyEntries)
        let host = makeHost(viewModel)

        // Act
        scroll(host, to: 1)

        // Assert
        XCTAssertEqual(viewModel.progressPercent, 100)
        XCTAssertTrue(host.contains("100% completed"))
    }

    func test_mathuratView_should_followPercentage_when_scrollingDownAndUp() {
        // Arrange
        let viewModel = makeViewModel(loader: manyEntries)
        let host = makeHost(viewModel)

        // Act
        scroll(host, to: 0.5)
        let halfway = viewModel.progressPercent
        scroll(host, to: 0)

        // Assert
        XCTAssertTrue((40...60).contains(halfway), "\(halfway)%")
        XCTAssertEqual(viewModel.progressPercent, 0)
    }

    func test_mathuratView_should_pinProgressBanner_when_headerScrollsAway() {
        // Arrange
        let viewModel = makeViewModel(loader: manyEntries)
        let host = makeHost(viewModel)
        let bannerBefore = host.contains("Morning session,")

        // Act
        scroll(host, to: 0.5)

        // Assert
        XCTAssertFalse(bannerBefore)
        XCTAssertTrue(host.contains("Morning session, \(viewModel.progressPercent)% completed"))
    }

    func test_mathuratView_should_scrollToTop_when_bannerIsTapped() {
        // Arrange
        let viewModel = makeViewModel(loader: manyEntries)
        let host = makeHost(viewModel)
        scroll(host, to: 0.6)

        let scrollView = host.firstView(of: UIScrollView.self)
        let offsetBefore = scrollView?.contentOffset.y ?? 0

        // Act
        let handled = host.tap("Morning session,")
        host.pump(1.5)

        // Assert
        let offsetAfter = scrollView?.contentOffset.y ?? 0
        XCTAssertTrue(handled)
        XCTAssertLessThan(offsetAfter, offsetBefore, "before \(offsetBefore) after \(offsetAfter)")
        XCTAssertFalse(host.contains("Morning session,"))
    }

    func test_mathuratView_should_openReadingSettings() {
        // Arrange
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)

        // Act
        host.tap("Reading Settings")
        host.pump(0.6)

        // Assert
        XCTAssertNotNil(host.controller.presentedViewController)
    }

    func test_mathuratView_should_openSettings_fromMoreButton() {
        // Arrange
        let viewModel = makeViewModel()
        let host = makeHost(viewModel)

        // Act
        host.tap("More")

        // Assert
        XCTAssertEqual(settingsOpened, 1)
    }

    func test_mathuratView_should_showErrorAndRetry_when_loadFails() {
        // Arrange
        let loader = FakeMathuratLoader()
        loader.error = MathuratLoadError.missingResource
        let viewModel = makeViewModel(loader: loader)
        let host = makeHost(viewModel)
        let showedError = host.contains("The Al-Mathurat text couldn't be loaded.")
        loader.error = nil

        // Act
        host.tap("Try Again")
        host.pump(0.4)

        // Assert
        XCTAssertTrue(showedError)
        XCTAssertTrue(host.contains("Al Fatihah (1-7)"))
    }

    func test_mathuratView_should_switchToEvening_when_threePMPassesWhileOpen() async {
        // Arrange
        let clock = TestClock(
            TestClock.date(year: 2026, month: 11, day: 4, hour: 15).addingTimeInterval(-0.5)
        )
        let viewModel = makeViewModel(clock: clock)
        let host = makeHost(viewModel)
        clock.now = TestClock.date(year: 2026, month: 11, day: 4, hour: 15)

        // Act
        await waitUntil(timeout: 5) { viewModel.time == .evening }
        host.pump(0.3)

        // Assert
        XCTAssertTrue(host.contains("Al-Mathurat Sughra · Evening dhikr"))
    }
}
