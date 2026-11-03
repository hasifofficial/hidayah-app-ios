//
//  TrackerViewTestSupport.swift
//  simple-quranTests
//

import SwiftUI
import UIKit
import XCTest
@testable import simple_quran

/// A task manager backed by an in-memory store and a fake notification
/// center, reading the time from `clock`.
@MainActor
func makeTrackerTaskManager(clock: TestClock = TestClock(Date())) -> TaskManager {
    TaskManager(
        store: makeInMemoryStore(),
        scheduler: TrackerNotificationScheduler(
            center: FakeNotificationCenter()
        ),
        now: { clock.now }
    )
}

extension ViewHost {
    /// Accessibility elements in every window of the app, which includes
    /// menus and dialogs UIKit shows outside the host window.
    func allWindowElements() -> [NSObject] {
        var result = elements()
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter { $0 !== window }
        for other in windows {
            collectElements(other, into: &result, depth: 0)
        }
        return result
    }

    func allWindowLabels() -> [String] {
        allWindowElements().compactMap(\.accessibilityLabel)
    }

    /// Activates the first element in any window whose label is exactly
    /// `label`, falling back to a label that contains it.
    @discardableResult
    func tapAnywhere(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let all = allWindowElements()
        guard let element = all.first(where: { $0.accessibilityLabel == label })
            ?? all.first(where: { ($0.accessibilityLabel ?? "").contains(label) }) else {
            XCTFail(
                "No element labelled \(label). Found: \(allWindowLabels())",
                file: file,
                line: line
            )
            return false
        }
        let handled = element.accessibilityActivate()
        pump()
        return handled
    }

    /// Runs the accessibility custom action `actionName` (e.g. a swipe-to-
    /// delete action) on the first element whose label contains `label`.
    @discardableResult
    func performCustomAction(
        _ actionName: String,
        on label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let candidates = allWindowElements().filter {
            ($0.accessibilityLabel ?? "").contains(label)
        }
        for element in candidates {
            guard let action = element.accessibilityCustomActions?.first(where: {
                $0.name.contains(actionName)
            }) else {
                continue
            }
            let handled: Bool
            if let handler = action.actionHandler {
                handled = handler(action)
            } else if let target = action.target as? NSObject {
                handled = target.perform(action.selector, with: action) != nil
            } else {
                handled = false
            }
            pump()
            return handled
        }
        XCTFail(
            "No \(actionName) action on \(label). Found: \(allWindowLabels())",
            file: file,
            line: line
        )
        return false
    }

    /// Every text field in the host window and presented controllers.
    func textFields() -> [UITextField] {
        presentedRoots().flatMap { Self.subviews(of: UITextField.self, in: $0) }
    }

    /// Every picker wheel in the host window and presented controllers.
    func pickerViews() -> [UIPickerView] {
        presentedRoots().flatMap { Self.subviews(of: UIPickerView.self, in: $0) }
    }

    /// Replaces the text of the text field at `index` the way typing would.
    func type(
        _ text: String,
        intoFieldAt index: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let fields = textFields()
        guard fields.indices.contains(index) else {
            XCTFail("No text field at \(index); found \(fields.count)", file: file, line: line)
            return
        }
        let field = fields[index]
        field.becomeFirstResponder()
        pump()
        if let range = field.textRange(
            from: field.beginningOfDocument,
            to: field.endOfDocument
        ) {
            field.replace(range, withText: text)
        }
        pump()
        field.resignFirstResponder()
        pump()
    }

    /// Picks `row` in a wheel picker, notifying its delegate as a user's
    /// scroll would.
    func select(
        row: Int,
        inPickerAt index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let pickers = pickerViews()
        guard pickers.indices.contains(index) else {
            XCTFail("No picker at \(index); found \(pickers.count)", file: file, line: line)
            return
        }
        let picker = pickers[index]
        picker.selectRow(row, inComponent: 0, animated: false)
        picker.delegate?.pickerView?(picker, didSelectRow: row, inComponent: 0)
        pump()
    }

    /// Activates the first element with the button trait whose label is
    /// exactly `label`, skipping titles and other static text that share it.
    @discardableResult
    func tapButton(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let element = elements().first(where: {
            $0.accessibilityLabel == label && $0.accessibilityTraits.contains(.button)
        }) else {
            XCTFail("No button labelled \(label). Found: \(labels())", file: file, line: line)
            return false
        }
        let handled = element.accessibilityActivate()
        pump()
        return handled
    }

    /// The alert or confirmation dialog presented over the host, if any.
    var presentedAlert: UIAlertController? {
        controller.presentedViewController as? UIAlertController
    }

    /// Runs the handler of the presented alert's action titled `title`, as
    /// tapping that button would.
    func chooseAlertAction(
        _ title: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let alert = presentedAlert else {
            XCTFail("No alert is presented", file: file, line: line)
            return
        }
        guard let action = alert.actions.first(where: { $0.title == title }),
              let handler = action.value(forKey: "handler") else {
            XCTFail(
                "No action \(title) in \(alert.actions.map { $0.title ?? "" })",
                file: file,
                line: line
            )
            return
        }
        typealias Handler = @convention(block) (UIAlertAction) -> Void
        unsafeBitCast(handler as AnyObject, to: Handler.self)(action)
        pump(0.3)
    }

    private func presentedRoots() -> [UIView] {
        var roots: [UIView] = [window]
        var presented = controller.presentedViewController
        while let next = presented {
            roots.append(next.view)
            presented = next.presentedViewController
        }
        return roots
    }

    private static func subviews<T: UIView>(of type: T.Type, in view: UIView) -> [T] {
        var found: [T] = []
        if let match = view as? T {
            found.append(match)
        }
        for subview in view.subviews {
            found += subviews(of: type, in: subview)
        }
        return found
    }

    private func collectElements(
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
                collectElements(element, into: &result, depth: depth + 1)
            }
        } else {
            let count = object.accessibilityElementCount()
            if count != NSNotFound, count > 0 {
                for index in 0..<count {
                    if let element = object.accessibilityElement(at: index) as? NSObject {
                        collectElements(element, into: &result, depth: depth + 1)
                    }
                }
            }
        }

        if let view = object as? UIView {
            for subview in view.subviews {
                collectElements(subview, into: &result, depth: depth + 1)
            }
        }
    }
}
