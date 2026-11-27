//
//  QiblaViewModel.swift
//  hidayah-app
//

import CoreLocation
import Foundation
import Observation

/// Haptics the compass plays while turning, injectable for tests.
@MainActor
struct QiblaHaptics {
    /// A tick each time the offset crosses a step; `closeness` runs from 0
    /// (facing away) to 1 (almost aligned) so ticks get stronger nearer.
    var step: (_ closeness: Double) -> Void
    var aligned: () -> Void

    #if os(watchOS)
    // Every Watch haptic carries a sound. Turning uses the quiet click
    // (the firmer one chimes), so the only real sound is the success chime
    // once you face the Qibla.
    static let live = QiblaHaptics(
        step: { _ in AppHaptics.tap() },
        aligned: { AppHaptics.success() }
    )
    #else
    static let live = QiblaHaptics(
        step: { AppHaptics.impact(intensity: 0.35 + 0.65 * $0) },
        aligned: { AppHaptics.success() }
    )
    #endif

    static let none = QiblaHaptics(step: { _ in }, aligned: {})
}

@MainActor
@Observable
final class QiblaViewModel {
    enum Status: Equatable {
        case needsPermission
        case denied
        case headingUnavailable
        case locating
        case ready
    }

    enum TurnDirection: Equatable {
        case left
        case right
    }

    /// Within this many degrees the user counts as facing the Qibla.
    static let alignTolerance = 5.0
    /// Once aligned, the user must drift past this to lose alignment, so
    /// the screen does not flicker at the edge.
    static let releaseTolerance = 8.0
    /// Degrees between haptic ticks while turning.
    static let hapticStep = 10.0
    /// Heading accuracy (degrees) worse than this asks for calibration.
    static let calibrationThreshold = 25.0

    private(set) var authorization: QiblaAuthorization
    private(set) var coordinate: CLLocationCoordinate2D?
    private(set) var heading: Double?
    private(set) var headingAccuracy: Double?
    private(set) var isAligned = false
    /// The arrow's rotation in degrees, unwrapped so animating across north
    /// takes the short way round.
    private(set) var arrowRotation: Double = 0

    @ObservationIgnored private let sensor: QiblaSensing
    @ObservationIgnored private let haptics: QiblaHaptics
    @ObservationIgnored private var lastHapticBucket: Int?

    init(sensor: QiblaSensing, haptics: QiblaHaptics = .live) {
        self.sensor = sensor
        self.haptics = haptics
        self.authorization = sensor.authorization
    }

    // MARK: Derived state

    var status: Status {
        switch authorization {
        case .notDetermined:
            return .needsPermission
        case .denied:
            return .denied
        case .authorized:
            break
        }
        guard sensor.isHeadingAvailable else { return .headingUnavailable }
        guard coordinate != nil, heading != nil else { return .locating }
        return .ready
    }

    var qiblaBearing: Double? {
        coordinate.map { QiblaMath.bearing(from: $0) }
    }

    var distanceKilometers: Double? {
        coordinate.map { QiblaMath.distance(from: $0) / 1000 }
    }

    /// How far to turn to face the Qibla, in `-180..<180`. Positive means
    /// turn right.
    var offset: Double? {
        guard let heading, let qiblaBearing else { return nil }
        return QiblaMath.signedDelta(from: heading, to: qiblaBearing)
    }

    var turnDirection: TurnDirection? {
        guard let offset, !isAligned else { return nil }
        return offset > 0 ? .right : .left
    }

    var needsCalibration: Bool {
        guard let headingAccuracy else { return false }
        return headingAccuracy < 0 || headingAccuracy > Self.calibrationThreshold
    }

    /// 0 when facing directly away, 1 when facing the Qibla.
    var closeness: Double {
        guard let offset else { return 0 }
        return 1 - abs(offset) / 180
    }

    var offsetText: String {
        guard let offset else { return "–" }
        return "\(Int(abs(offset).rounded()))°"
    }

    var guidanceText: String {
        if isAligned {
            return NSLocalizedString("qibla_guidance_aligned", comment: "")
        }
        switch turnDirection {
        case .left:
            return NSLocalizedString("qibla_guidance_left", comment: "")
        case .right:
            return NSLocalizedString("qibla_guidance_right", comment: "")
        case nil:
            return ""
        }
    }

    var distanceText: String? {
        guard let distanceKilometers else { return nil }
        let measurement = Measurement(
            value: distanceKilometers.rounded(),
            unit: UnitLength.kilometers
        )
        let distance = measurement.formatted(
            .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0)))
        )
        return String(
            format: NSLocalizedString("qibla_distance_format", comment: ""),
            distance
        )
    }

    var bearingText: String? {
        guard let qiblaBearing else { return nil }
        return String(
            format: NSLocalizedString("qibla_bearing_format", comment: ""),
            Int(qiblaBearing.rounded())
        )
    }

    // MARK: Actions

    func onAppear() {
        sensor.onEvent = { [weak self] event in
            self?.handle(event)
        }
        authorization = sensor.authorization
        if authorization == .notDetermined {
            sensor.requestAuthorization()
        }
        sensor.start()
    }

    func onDisappear() {
        sensor.stop()
    }

    func requestPermission() {
        sensor.requestAuthorization()
    }

    func handle(_ event: QiblaSensorEvent) {
        switch event {
        case .authorization(let authorization):
            self.authorization = authorization
        case .location(let latitude, let longitude):
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            update()
        case .heading(let degrees, let accuracy):
            heading = QiblaMath.normalized(degrees)
            headingAccuracy = accuracy
            update()
        }
    }

    private func update() {
        guard let offset else { return }

        arrowRotation += QiblaMath.signedDelta(
            from: QiblaMath.normalized(arrowRotation),
            to: offset
        )

        let distance = abs(offset)
        let wasAligned = isAligned
        isAligned = wasAligned
            ? distance <= Self.releaseTolerance
            : distance <= Self.alignTolerance

        if isAligned && !wasAligned {
            haptics.aligned()
        }

        let bucket = Int(distance / Self.hapticStep)
        if !isAligned, let lastHapticBucket, bucket != lastHapticBucket {
            haptics.step(closeness)
        }
        lastHapticBucket = bucket
    }
}
