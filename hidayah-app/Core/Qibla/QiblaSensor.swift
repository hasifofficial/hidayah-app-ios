//
//  QiblaSensor.swift
//  hidayah-app
//

import CoreLocation

enum QiblaAuthorization: Equatable {
    case notDetermined
    case denied
    case authorized
}

/// What the Qibla compass hears from the device.
enum QiblaSensorEvent: Equatable {
    case authorization(QiblaAuthorization)
    case location(latitude: Double, longitude: Double)
    /// `degrees` is clockwise from true north. A negative `accuracy` means
    /// the compass needs calibrating.
    case heading(degrees: Double, accuracy: Double)
}

/// Location and compass source for the Qibla screen, so the view model can
/// be driven by a fake in tests.
@MainActor
protocol QiblaSensing: AnyObject {
    var authorization: QiblaAuthorization { get }
    var isHeadingAvailable: Bool { get }
    var onEvent: ((QiblaSensorEvent) -> Void)? { get set }

    func requestAuthorization()
    func start()
    func stop()
}

/// `QiblaSensing` backed by Core Location.
@MainActor
final class CoreLocationQiblaSensor: NSObject, QiblaSensing {
    var onEvent: ((QiblaSensorEvent) -> Void)?

    private let manager: CLLocationManager

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.headingFilter = 1
        #if os(iOS)
        manager.headingOrientation = .portrait
        #endif
    }

    var authorization: QiblaAuthorization {
        Self.map(manager.authorizationStatus)
    }

    var isHeadingAvailable: Bool {
        CLLocationManager.headingAvailable()
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        guard authorization == .authorized else { return }
        manager.startUpdatingLocation()
        if isHeadingAvailable {
            manager.startUpdatingHeading()
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    private func send(_ event: QiblaSensorEvent) {
        onEvent?(event)
    }

    private static func map(_ status: CLAuthorizationStatus) -> QiblaAuthorization {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        default:
            return .denied
        }
    }
}

extension CoreLocationQiblaSensor: CLLocationManagerDelegate {
    // Core Location calls back on the thread that created the manager,
    // which is the main thread here.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            let authorization = Self.map(status)
            send(.authorization(authorization))
            if authorization == .authorized {
                start()
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let coordinate = locations.last?.coordinate else { return }
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        MainActor.assumeIsolated {
            send(.location(latitude: latitude, longitude: longitude))
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {
        // True north needs a location fix; until then fall back to magnetic.
        let degrees = newHeading.trueHeading >= 0
            ? newHeading.trueHeading
            : newHeading.magneticHeading
        let accuracy = newHeading.headingAccuracy
        MainActor.assumeIsolated {
            send(.heading(degrees: degrees, accuracy: accuracy))
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Transient failures (no fix yet) are retried by Core Location.
    }

    #if os(iOS)
    nonisolated func locationManagerShouldDisplayHeadingCalibration(
        _ manager: CLLocationManager
    ) -> Bool {
        true
    }
    #endif
}
