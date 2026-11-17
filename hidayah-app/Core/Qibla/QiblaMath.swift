//
//  QiblaMath.swift
//  hidayah-app
//

import CoreLocation

/// Great-circle maths for finding the Qibla. Angles are in degrees,
/// measured clockwise from true north.
enum QiblaMath {
    /// The Kaaba in Masjid al-Haram, Makkah.
    static let kaaba = CLLocationCoordinate2D(
        latitude: 21.422487,
        longitude: 39.826206
    )

    private static let earthRadiusMeters = 6_371_008.8

    /// The initial great-circle bearing from `origin` to `destination`,
    /// in `0..<360`.
    static func bearing(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D = kaaba
    ) -> Double {
        let lat1 = radians(origin.latitude)
        let lat2 = radians(destination.latitude)
        let deltaLon = radians(destination.longitude - origin.longitude)

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)

        return normalized(degrees(atan2(y, x)))
    }

    /// The great-circle distance in meters from `origin` to `destination`.
    static func distance(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D = kaaba
    ) -> CLLocationDistance {
        let lat1 = radians(origin.latitude)
        let lat2 = radians(destination.latitude)
        let deltaLat = lat2 - lat1
        let deltaLon = radians(destination.longitude - origin.longitude)

        let a = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusMeters * c
    }

    /// `angle` wrapped into `0..<360`.
    static func normalized(_ angle: Double) -> Double {
        let wrapped = angle.truncatingRemainder(dividingBy: 360)
        return wrapped < 0 ? wrapped + 360 : wrapped
    }

    /// The shortest turn from `start` to `end`, in `-180..<180`. Positive
    /// turns clockwise (to the right).
    static func signedDelta(from start: Double, to end: Double) -> Double {
        let delta = normalized(end - start)
        return delta >= 180 ? delta - 360 : delta
    }

    private static func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    private static func degrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }
}
