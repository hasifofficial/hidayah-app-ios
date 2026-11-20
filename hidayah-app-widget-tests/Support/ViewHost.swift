//
//  ViewHost.swift
//  app-widgetTests
//

import SwiftUI
import UIKit
import XCTest

/// SwiftUI only builds its accessibility tree while an assistive technology
/// is active; turning on automation mode (what UI tests use) makes it build
/// one for hosted views too.
private let enableAccessibilityAutomation: Void = {
    guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
          let symbol = dlsym(handle, "_AXSSetAutomationEnabled") else {
        return
    }
    typealias SetEnabled = @convention(c) (Int32) -> Void
    unsafeBitCast(symbol, to: SetEnabled.self)(1)
}()

/// Renders a SwiftUI view in a real window so its body, `onAppear` and
/// accessibility tree run, and lets tests activate controls by label.
@MainActor
final class ViewHost<Content: View> {
    let window: UIWindow
    let controller: UIHostingController<Content>

    init(
        _ content: Content,
        size: CGSize = CGSize(width: 402, height: 2400)
    ) {
        _ = enableAccessibilityAutomation
        controller = UIHostingController(rootView: content)
        window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.frame = window.bounds
        controller.view.layoutIfNeeded()
        pump()
    }

    /// Lets SwiftUI process state changes, animations and `task` work.
    func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        controller.view.layoutIfNeeded()
    }

    /// Every accessibility element currently on screen, including ones in
    /// presented sheets and alerts.
    func elements() -> [NSObject] {
        var result: [NSObject] = []
        var roots: [NSObject] = [window]
        var presented = controller.presentedViewController
        while let next = presented {
            roots.append(next.view)
            presented = next.presentedViewController
        }
        for root in roots {
            collect(root, into: &result, depth: 0)
        }
        return result
    }

    func labels() -> [String] {
        elements().compactMap(\.accessibilityLabel)
    }

    func contains(_ text: String) -> Bool {
        labels().contains { $0.contains(text) }
    }

    /// Activates the first element whose label contains `label`, the way
    /// VoiceOver would. Returns false when no such element exists.
    @discardableResult
    func tap(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let element = elements().first(where: {
            ($0.accessibilityLabel ?? "").contains(label)
        }) else {
            XCTFail("No element labelled \(label). Found: \(labels())", file: file, line: line)
            return false
        }
        let handled = element.accessibilityActivate()
        pump()
        return handled
    }

    private func collect(
        _ object: NSObject,
        into result: inout [NSObject],
        depth: Int
    ) {
        guard depth < 60 else { return }

        if object.isAccessibilityElement {
            result.append(object)
        }

        if let elements = object.accessibilityElements as? [NSObject] {
            for element in elements {
                collect(element, into: &result, depth: depth + 1)
            }
        } else {
            let count = object.accessibilityElementCount()
            if count != NSNotFound, count > 0 {
                for index in 0..<count {
                    if let element = object.accessibilityElement(at: index) as? NSObject {
                        collect(element, into: &result, depth: depth + 1)
                    }
                }
            }
        }

        if let view = object as? UIView {
            for subview in view.subviews {
                collect(subview, into: &result, depth: depth + 1)
            }
        }
    }
}
