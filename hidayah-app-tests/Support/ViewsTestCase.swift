//
//  ViewsTestCase.swift
//  simple-quranTests
//
//  Base class for view tests: hosts views in the app's window scene (so
//  navigation pushes, sheets and list updates animate to completion) and
//  removes those windows after each test.
//

import SwiftUI
import UIKit
import XCTest

@MainActor
class ViewsTestCase: XCTestCase {
    private var cleanups: [() -> Void] = []

    override func tearDown() {
        for cleanup in cleanups.reversed() {
            cleanup()
        }
        cleanups = []
        super.tearDown()
    }

    /// A `ViewHost` whose window lives in the app's window scene.
    func sceneHost<Content: View>(
        _ content: Content,
        size: CGSize = CGSize(width: 402, height: 2400)
    ) -> ViewHost<Content> {
        let host = ViewHost(content, size: size)
        host.attachToScene()
        cleanups.append { host.tearDown() }
        return host
    }
}
