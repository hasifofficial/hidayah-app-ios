//
//  ProximitySensor.swift
//  hidayah-app
//

import UIKit

/// Tells the rakaat counter when something is close to the top of the
/// phone: the forehead in sujood, with the phone face up on the mat.
@MainActor
protocol ProximitySensing: AnyObject {
    /// False on devices without the sensor, such as the Simulator and iPad.
    /// Only known after `start`.
    var isAvailable: Bool { get }
    func start(onChange: @escaping @MainActor (_ isNear: Bool) -> Void)
    func stop()
}

/// The iPhone's proximity sensor. While it runs, the screen stays awake
/// between sujood; iOS turns the display off itself while something is
/// near.
@MainActor
final class DeviceProximitySensor: ProximitySensing {
    private(set) var isAvailable = false
    private var observer: NSObjectProtocol?
    private var onChange: (@MainActor (_ isNear: Bool) -> Void)?

    func start(onChange: @escaping @MainActor (_ isNear: Bool) -> Void) {
        self.onChange = onChange
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        // Setting it has no effect on devices without the sensor.
        isAvailable = device.isProximityMonitoringEnabled
        UIApplication.shared.isIdleTimerDisabled = true

        guard isAvailable, observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.proximityStateDidChangeNotification,
            object: device,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.onChange?(UIDevice.current.proximityState)
            }
        }
    }

    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        onChange = nil
        UIDevice.current.isProximityMonitoringEnabled = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
