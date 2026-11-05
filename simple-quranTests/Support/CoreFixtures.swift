//
//  CoreFixtures.swift
//  simple-quranTests
//

import Foundation
import SwiftData
import UserNotifications
import XCTest
@testable import simple_quran

// MARK: - Store

enum CoreTestError: Error {
    case unavailable
}

/// Builds containers for `HidayahStore(makeContainer:)`, failing the first
/// `failures` attempts so tests can drive the in-memory fallback and
/// `reconnectIfNeeded()`.
@MainActor
final class FlakyContainerFactory {
    private var failuresRemaining: Int
    private(set) var attempts = 0

    init(failures: Int) {
        failuresRemaining = failures
    }

    func make() throws -> ModelContainer {
        attempts += 1
        if failuresRemaining > 0 {
            failuresRemaining -= 1
            throw CoreTestError.unavailable
        }
        return HidayahStore.makeInMemoryContainer()
    }
}

@MainActor
func makeFailingStore() -> HidayahStore {
    HidayahStore(makeContainer: { throw CoreTestError.unavailable })
}

// MARK: - Tracker

@MainActor
func makeTaskManager(
    store: HidayahStore,
    center: FakeNotificationCenter = FakeNotificationCenter(),
    clock: TestClock
) -> TaskManager {
    TaskManager(
        store: store,
        scheduler: TrackerNotificationScheduler(center: center),
        now: { clock.now }
    )
}

func makeTask(
    _ name: String,
    category: simple_quran.Category = .default(.fajr),
    isCompleted: Bool = false
) -> TaskDetails {
    TaskDetails(name: name, category: category, isCompleted: isCompleted)
}

func makeRecord(
    _ dayKey: String,
    completed: Int,
    total: Int
) -> TrackerDayRecord {
    let tasks = (0..<total).map { index in
        TrackerTaskSnapshot(
            task: makeTask("Task \(index)", isCompleted: index < completed)
        )
    }
    return TrackerDayRecord(dayKey: dayKey, tasks: tasks)
}

func loadWidgetContext() -> WidgetContext? {
    Storage.loadObject(key: .widgetContext)
}

// MARK: - Notifications

/// `UNNotification` and `UNNotificationResponse` have no public initialisers;
/// these use the class factories UserNotifications itself uses.
func makeNotification(userInfo: [AnyHashable: Any]) -> UNNotification {
    let content = UNMutableNotificationContent()
    content.userInfo = userInfo
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil
    )
    let factory = UNNotification.self as AnyObject
    return factory.perform(
        NSSelectorFromString("notificationWithRequest:date:"),
        with: request,
        with: Date()
    )!.takeUnretainedValue() as! UNNotification
}

func makeNotificationResponse(userInfo: [AnyHashable: Any]) -> UNNotificationResponse {
    let factory = UNNotificationResponse.self as AnyObject
    return factory.perform(
        NSSelectorFromString("responseWithNotification:actionIdentifier:"),
        with: makeNotification(userInfo: userInfo),
        with: UNNotificationDefaultActionIdentifier
    )!.takeUnretainedValue() as! UNNotificationResponse
}

// MARK: - Networking

/// Answers every request with a non-HTTP response, which a real server
/// never produces, to reach `RequestError.noResponse`.
final class CoreNonHTTPURLProtocol: URLProtocol {
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CoreNonHTTPURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response = URLResponse(
            url: request.url!,
            mimeType: "application/json",
            expectedContentLength: 2,
            textEncodingName: nil
        )
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("{}".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

/// An endpoint whose every part a test can choose.
struct CoreTestEndpoint: Endpoint {
    var path: String = "/v1/test"
    var method: RequestMethod = .get
    var header: [String: String]?
    var body: [String: String]?
}

struct CoreEcho: Codable, Equatable {
    let value: String
}

extension URLRequest {
    /// The body as sent; URLSession moves `httpBody` into a stream before a
    /// URL protocol sees the request.
    var sentBody: Data? {
        if let httpBody {
            return httpBody
        }
        guard let stream = httpBodyStream else { return nil }

        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
