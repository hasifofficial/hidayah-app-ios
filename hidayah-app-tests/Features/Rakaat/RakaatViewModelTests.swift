//
//  RakaatViewModelTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

@MainActor
private final class FakeProximitySensor: ProximitySensing {
    var isAvailable = true
    private(set) var isRunning = false
    private var onChange: (@MainActor (Bool) -> Void)?

    func start(onChange: @escaping @MainActor (Bool) -> Void) {
        isRunning = true
        self.onChange = onChange
    }

    func stop() {
        isRunning = false
        onChange = nil
    }

    func send(isNear: Bool) {
        onChange?(isNear)
    }
}

@MainActor
private final class SpyWatchLink: RakaatWatchLink {
    var isWatchReachable = true
    var rakaatCommandHandler: ((RakaatCommand) -> Void)?
    private(set) var sent: [RakaatLiveState] = []

    func sendRakaat(_ state: RakaatLiveState) {
        sent.append(state)
    }
}

@MainActor
private final class FakeScreen: ScreenBrightnessControlling {
    var brightness: CGFloat = 0.8
}

@MainActor
final class RakaatViewModelTests: XCTestCase {
    private var sensor: FakeProximitySensor!
    private var link: SpyWatchLink!
    private var clock: TestClock!
    private var screen: FakeScreen!
    private var scheduled: [@MainActor () -> Void] = []

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        sensor = FakeProximitySensor()
        link = SpyWatchLink()
        screen = FakeScreen()
        clock = TestClock(Date(timeIntervalSince1970: 3_000_000))
        scheduled = []
    }

    override func tearDown() async throws {
        resetStorage()
        sensor = nil
        link = nil
        screen = nil
        clock = nil
        scheduled = []
        try await super.tearDown()
    }

    private func makeViewModel() -> RakaatViewModel {
        RakaatViewModel(
            sensor: sensor,
            watchLink: link,
            now: { [clock] in clock!.now },
            schedule: { [weak self] _, action in self?.scheduled.append(action) },
            playsHaptics: false,
            screen: screen
        )
    }

    /// Runs whatever is waiting on the scheduler, such as the fade to black.
    private func runScheduled() {
        let actions = scheduled
        scheduled = []
        actions.forEach { $0() }
    }

    /// One sujood through the fake sensor, then runs the scheduled settle.
    private func sujood(_ viewModel: RakaatViewModel) {
        sensor.send(isNear: true)
        clock.now += 2
        sensor.send(isNear: false)
        clock.now += RakaatCounter.flickerGap + 0.05
        let actions = scheduled
        scheduled = []
        actions.forEach { $0() }
        clock.now += 1
    }

    func test_start_should_runSensorAndTellWatch() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.prayer = .asr

        // Act
        viewModel.start()

        // Assert
        XCTAssertEqual(viewModel.phase, .praying)
        XCTAssertTrue(sensor.isRunning)
        XCTAssertEqual(link.sent.last?.prayer, .asr)
        XCTAssertEqual(link.sent.last?.isActive, true)
        XCTAssertEqual(link.sent.last?.sequence, 1)
        XCTAssertNotNil(link.rakaatCommandHandler)
    }

    func test_twoSujood_should_countRakaatAndSendEvents() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.prayer = .dhuhr
        viewModel.start()

        // Act
        sujood(viewModel)
        sujood(viewModel)

        // Assert
        XCTAssertEqual(viewModel.completedRakaat, 1)
        XCTAssertEqual(viewModel.currentRakaat, 2)
        XCTAssertEqual(link.sent.last?.events, [.sujoodCounted(2), .rakaatCompleted(1)])
        XCTAssertEqual(link.sent.map(\.sequence), [1, 2, 3])
    }

    func test_secondRakaat_should_promptTashahhud() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.prayer = .maghrib
        viewModel.start()
        viewModel.increment()

        // Act
        viewModel.increment()

        // Assert
        XCTAssertTrue(viewModel.isTashahhudPrompt)
        XCTAssertEqual(link.sent.last?.events, [.rakaatCompleted(2), .tashahhud(isFinal: false)])
    }

    func test_lastRakaat_should_finishAndStopSensor() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.prayer = .fajr
        viewModel.start()
        viewModel.increment()

        // Act
        sujood(viewModel)
        sujood(viewModel)

        // Assert
        XCTAssertEqual(viewModel.phase, .finished)
        XCTAssertFalse(sensor.isRunning)
        XCTAssertEqual(link.sent.last?.isActive, false)
        XCTAssertEqual(link.sent.last?.events.last, .prayerCompleted)
        XCTAssertNil(link.rakaatCommandHandler)
    }

    func test_stop_should_endSessionOnWatch() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()

        // Act
        viewModel.stop()

        // Assert
        XCTAssertEqual(viewModel.phase, .setup)
        XCTAssertFalse(sensor.isRunning)
        XCTAssertEqual(link.sent.last?.isActive, false)
    }

    func test_watchCommand_should_adjustCount_when_sessionMatches() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.prayer = .isha
        viewModel.start()
        let sessionID = viewModel.sessionID

        // Act
        link.rakaatCommandHandler?(RakaatCommand(sessionID: sessionID, action: .increment))
        link.rakaatCommandHandler?(RakaatCommand(sessionID: UUID(), action: .increment))

        // Assert
        XCTAssertEqual(viewModel.completedRakaat, 1)
    }

    func test_decrement_should_sendUpdatedCount() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        viewModel.increment()

        // Act
        viewModel.decrement()

        // Assert
        XCTAssertEqual(viewModel.completedRakaat, 0)
        XCTAssertEqual(link.sent.last?.completedRakaat, 0)
        XCTAssertEqual(link.sent.last?.events, [])
    }

    func test_sensorChanges_should_beIgnored_when_notPraying() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        viewModel.proximityChanged(isNear: true)
        viewModel.increment()

        // Assert
        XCTAssertEqual(viewModel.completedRakaat, 0)
        XCTAssertEqual(link.sent, [])
    }

    func test_prayer_should_fallBackToDhuhr_when_savedPrayerWasRemoved() {
        // Arrange
        // Sunnah was a choice in earlier builds; it is saved like this.
        Storage.save(.rakaatLastPrayer, Data(#"{"sunnah":{}}"#.utf8))

        // Act
        let viewModel = makeViewModel()

        // Assert
        XCTAssertEqual(viewModel.prayer, .dhuhr)
    }

    func test_prayer_should_beRemembered() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        viewModel.prayer = .custom(rakaat: 8)
        let reopened = makeViewModel()

        // Assert
        XCTAssertEqual(reopened.prayer, .custom(rakaat: 8))
    }

    func test_unavailableSensor_should_beReported() {
        // Arrange
        sensor.isAvailable = false
        let viewModel = makeViewModel()

        // Act
        viewModel.start()

        // Assert
        XCTAssertFalse(viewModel.isSensorAvailable)
    }

    // MARK: - Focus screen

    func test_start_should_showCountingScreenFirst_when_focusScreenIsOn() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        viewModel.start()

        // Assert
        XCTAssertTrue(viewModel.usesFocusScreen)
        XCTAssertFalse(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, 0.8)
    }

    func test_start_should_fadeToBlackAndDim_when_delayPasses() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()

        // Act
        runScheduled()

        // Assert
        XCTAssertTrue(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, RakaatViewModel.focusBrightness)
    }

    func test_wakeScreen_should_restoreBrightnessThenFadeAgain() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        runScheduled()

        // Act
        viewModel.wakeScreen()
        let isDarkAfterWaking = viewModel.showsFocusScreen
        let brightnessAfterWaking = screen.brightness
        runScheduled()

        // Assert
        XCTAssertFalse(isDarkAfterWaking)
        XCTAssertEqual(brightnessAfterWaking, 0.8)
        XCTAssertTrue(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, RakaatViewModel.focusBrightness)
    }

    func test_wakeScreen_should_cancelEarlierFade() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        let startFade = scheduled
        scheduled = []
        viewModel.wakeScreen()

        // Act
        startFade.forEach { $0() }

        // Assert
        XCTAssertFalse(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, 0.8)
    }

    func test_fade_should_notHappen_when_stoppedFirst() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        viewModel.stop()

        // Act
        runScheduled()

        // Assert
        XCTAssertFalse(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, 0.8)
    }

    func test_stop_should_restoreBrightness() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        runScheduled()

        // Act
        viewModel.stop()

        // Assert
        XCTAssertEqual(screen.brightness, 0.8)
        XCTAssertFalse(viewModel.showsFocusScreen)
    }

    func test_finishing_should_restoreBrightness() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.prayer = .custom(rakaat: 1)
        viewModel.start()
        runScheduled()

        // Act
        viewModel.increment()

        // Assert
        XCTAssertEqual(viewModel.phase, .finished)
        XCTAssertFalse(viewModel.isScreenDark)
        XCTAssertEqual(screen.brightness, 0.8)
    }

    func test_start_should_keepBrightness_when_focusScreenIsOff() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.usesFocusScreen = false

        // Act
        viewModel.start()
        runScheduled()

        // Assert
        XCTAssertFalse(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, 0.8)
    }

    func test_turningFocusOff_should_restoreBrightness_when_praying() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        runScheduled()

        // Act
        viewModel.usesFocusScreen = false

        // Assert
        XCTAssertFalse(viewModel.showsFocusScreen)
        XCTAssertEqual(screen.brightness, 0.8)
        XCTAssertEqual(makeViewModel().usesFocusScreen, false)
    }

    func test_returningToForeground_should_dimAgainWithoutLosingBrightness() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.start()
        runScheduled()
        viewModel.sceneWillResignActive()

        // Act
        viewModel.sceneDidBecomeActive()
        viewModel.sceneDidBecomeActive()
        viewModel.stop()

        // Assert
        XCTAssertEqual(screen.brightness, 0.8)
    }
}
