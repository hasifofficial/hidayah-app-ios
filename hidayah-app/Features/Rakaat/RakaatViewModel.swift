//
//  RakaatViewModel.swift
//  hidayah-app
//

import Foundation
import Observation

/// Where the iPhone sends its live session so the Watch can show it and
/// play the cues on the wrist. `WatchSyncService` is the real one.
@MainActor
protocol RakaatWatchLink: AnyObject {
    /// True when a Watch app is open to receive live updates.
    var isWatchReachable: Bool { get }
    var rakaatCommandHandler: ((RakaatCommand) -> Void)? { get set }
    func sendRakaat(_ state: RakaatLiveState)
}

/// Runs one prayer at a time: the proximity sensor feeds a
/// `RakaatCounter`, and each rakaat plays a cue and updates the Watch.
@MainActor
@Observable
final class RakaatViewModel {
    enum Phase: Equatable {
        case setup
        case praying
        case finished
    }

    /// Runs `action` after `delay` seconds. Injected so tests can run it
    /// straight away.
    typealias Scheduler = (_ delay: TimeInterval, _ action: @escaping @MainActor @Sendable () -> Void) -> Void

    var prayer: RakaatPrayer {
        didSet { Storage.saveRakaatPrayer(prayer) }
    }
    /// Fades the counting screen to black with only the count while you
    /// pray, and dims the display. On OLED screens black pixels are off.
    var usesFocusScreen: Bool {
        didSet {
            Storage.save(.rakaatFocusScreen, usesFocusScreen)
            guard phase == .praying else { return }
            if usesFocusScreen {
                scheduleFade(after: Self.fadeDelay)
            } else {
                cancelFade()
            }
        }
    }
    private(set) var counter: RakaatCounter
    private(set) var phase: Phase = .setup
    private(set) var isSensorAvailable = true
    /// The latest tashahhud cue, shown on screen until the next rakaat.
    private(set) var isTashahhudPrompt = false
    /// True once the counting screen has faded to black.
    private(set) var isScreenDark = false

    @ObservationIgnored private let sensor: ProximitySensing
    @ObservationIgnored private let watchLink: RakaatWatchLink?
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let schedule: Scheduler
    @ObservationIgnored private let playsHaptics: Bool
    @ObservationIgnored private(set) var sessionID = UUID()
    @ObservationIgnored private var sequence = 0
    @ObservationIgnored private let screen: ScreenBrightnessControlling?
    /// Your brightness before dimming, while the screen is dimmed.
    @ObservationIgnored private var savedBrightness: CGFloat?
    /// Bumped whenever a pending fade should no longer happen.
    @ObservationIgnored private var fadeGeneration = 0

    /// Low enough to read in a dark room without lighting it up.
    static let focusBrightness: CGFloat = 0.05
    /// How long the counting screen shows before it fades to black, so you
    /// can see the prayer has started.
    static let fadeDelay: TimeInterval = 3
    /// How long the counting screen stays after you wake it.
    static let wakeDuration: TimeInterval = 8

    init(
        sensor: ProximitySensing = DeviceProximitySensor(),
        watchLink: RakaatWatchLink? = WatchSyncService.shared,
        now: @escaping () -> Date = Date.init,
        schedule: @escaping Scheduler = RakaatViewModel.defaultSchedule,
        playsHaptics: Bool = true,
        screen: ScreenBrightnessControlling? = DeviceScreenBrightness()
    ) {
        let prayer = Storage.loadRakaatPrayer() ?? .dhuhr
        self.prayer = prayer
        self.counter = RakaatCounter(prayer: prayer)
        self.sensor = sensor
        self.watchLink = watchLink
        self.now = now
        self.schedule = schedule
        self.playsHaptics = playsHaptics
        self.screen = screen
        self.usesFocusScreen = Storage.load(key: .rakaatFocusScreen) as? Bool ?? true
    }

    /// Whether the black focus screen is showing now.
    var showsFocusScreen: Bool { phase == .praying && usesFocusScreen && isScreenDark }

    var completedRakaat: Int { counter.completedRakaat }
    var rakaatCount: Int { counter.rakaatCount }
    var sujoodInCurrentRakaat: Int { counter.sujoodInCurrentRakaat }
    var progress: Double { counter.progress }

    /// The rakaat you are on now, from 1.
    var currentRakaat: Int { min(counter.completedRakaat + 1, counter.rakaatCount) }

    func start() {
        counter = RakaatCounter(prayer: prayer)
        sessionID = UUID()
        sequence = 0
        isTashahhudPrompt = false
        phase = .praying

        watchLink?.rakaatCommandHandler = { [weak self] command in
            self?.handle(command)
        }
        sensor.start { [weak self] isNear in
            self?.proximityChanged(isNear: isNear)
        }
        isSensorAvailable = sensor.isAvailable
        isScreenDark = false
        if usesFocusScreen {
            scheduleFade(after: Self.fadeDelay)
        }
        sendState(events: [])
    }

    /// Brings back the counting screen, then fades to black again after
    /// a while. Call it when you touch the screen.
    func wakeScreen() {
        guard phase == .praying, usesFocusScreen else { return }
        isScreenDark = false
        restoreBrightness()
        scheduleFade(after: Self.wakeDuration)
    }

    /// iOS puts your brightness back when the app leaves the foreground,
    /// so dim again on return.
    func sceneDidBecomeActive() {
        guard showsFocusScreen else { return }
        dimScreen()
    }

    func sceneWillResignActive() {
        restoreBrightness()
    }

    /// Ends the session early, for example when you leave the screen.
    func stop() {
        guard phase == .praying else { return }
        endSession()
        phase = .setup
    }

    /// Back to choosing a prayer after one is complete.
    func done() {
        phase = .setup
    }

    func increment() {
        guard phase == .praying else { return }
        apply(counter.manualIncrement())
    }

    func decrement() {
        guard phase == .praying else { return }
        counter.manualDecrement()
        isTashahhudPrompt = false
        sendState(events: [])
    }

    func proximityChanged(isNear: Bool) {
        guard phase == .praying else { return }
        let events = counter.proximityChanged(isNear: isNear, at: now())
        apply(events)
        if !isNear {
            // Count the sujood once the flicker gap has passed, without
            // waiting for the next sensor change.
            schedule(RakaatCounter.flickerGap + 0.05) { [weak self] in
                self?.advance()
            }
        }
    }

    func advance() {
        guard phase == .praying else { return }
        apply(counter.advance(to: now()))
    }

    // MARK: - Private

    private func handle(_ command: RakaatCommand) {
        guard command.sessionID == sessionID else { return }
        switch command.action {
        case .increment:
            increment()
        case .decrement:
            decrement()
        }
    }

    private func apply(_ events: [RakaatEvent]) {
        guard !events.isEmpty else { return }

        if events.contains(where: { if case .rakaatCompleted = $0 { return true } else { return false } }) {
            isTashahhudPrompt = events.contains(.tashahhud(isFinal: false))
                || events.contains(.tashahhud(isFinal: true))
        }

        // A phone on the mat can't be felt, so the Watch plays the cues
        // when it's there; otherwise the phone plays them.
        if playsHaptics, !(watchLink?.isWatchReachable ?? false) {
            RakaatFeedback.play(for: events)
        }

        if events.contains(.prayerCompleted) {
            sendState(events: events, isActive: false)
            sensor.stop()
            cancelFade()
            watchLink?.rakaatCommandHandler = nil
            phase = .finished
        } else {
            sendState(events: events)
        }
    }

    private func endSession() {
        sensor.stop()
        cancelFade()
        watchLink?.rakaatCommandHandler = nil
        sendState(events: [], isActive: false)
    }

    private func scheduleFade(after delay: TimeInterval) {
        fadeGeneration += 1
        let generation = fadeGeneration
        schedule(delay) { [weak self] in
            guard let self, generation == self.fadeGeneration,
                  self.phase == .praying, self.usesFocusScreen else { return }
            self.isScreenDark = true
            self.dimScreen()
        }
    }

    /// Back to the normal screen and brightness, with no fade pending.
    private func cancelFade() {
        fadeGeneration += 1
        isScreenDark = false
        restoreBrightness()
    }

    private func dimScreen() {
        guard let screen, savedBrightness == nil else { return }
        savedBrightness = screen.brightness
        screen.brightness = Self.focusBrightness
    }

    private func restoreBrightness() {
        guard let screen, let saved = savedBrightness else { return }
        screen.brightness = saved
        savedBrightness = nil
    }

    private func sendState(events: [RakaatEvent], isActive: Bool = true) {
        sequence += 1
        watchLink?.sendRakaat(
            RakaatLiveState(
                sessionID: sessionID,
                prayer: counter.prayer,
                completedRakaat: counter.completedRakaat,
                sujoodInCurrentRakaat: counter.sujoodInCurrentRakaat,
                isActive: isActive,
                sequence: sequence,
                events: events,
                updatedAt: now()
            )
        )
    }

    static let defaultSchedule: Scheduler = { delay, action in
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            action()
        }
    }
}

extension Storage {
    static func saveRakaatPrayer(_ prayer: RakaatPrayer) {
        guard let data = try? JSONEncoder().encode(prayer) else { return }
        save(.rakaatLastPrayer, data)
    }

    static func loadRakaatPrayer() -> RakaatPrayer? {
        loadObject(key: .rakaatLastPrayer)
    }
}
