//
//  ViewsHostHelpers.swift
//  simple-quranTests
//
//  Extra lookups on top of ViewHost for view tests.
//

import SwiftUI
import UIKit
import XCTest

extension ViewHost {
    /// Activates the last element whose label contains `label`; alerts and
    /// sheets sit at the end of `elements()`, so this targets them.
    @discardableResult
    func tapLast(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let element = elements().last(where: {
            ($0.accessibilityLabel ?? "").contains(label)
        }) else {
            XCTFail("No element labelled \(label). Found: \(labels())", file: file, line: line)
            return false
        }
        let handled = element.accessibilityActivate()
        pump()
        return handled
    }

    /// Waits on the run loop until `condition` holds or `timeout` passes.
    @discardableResult
    func pump(
        until condition: () -> Bool,
        timeout: TimeInterval = 5
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            if Date() > deadline { return false }
            pump(0.05)
        }
        return true
    }

    /// SwiftUI toggles on screen, once each, in order (their accessibility
    /// nodes report "0"/"1"; the backing UISwitch views are skipped).
    func switches() -> [NSObject] {
        var seen = Set<ObjectIdentifier>()
        return elements().filter {
            let value = $0.accessibilityValue ?? ""
            return !($0 is UIView)
                && (value == "0" || value == "1")
                && $0.accessibilityTraits.contains(.button)
                && seen.insert(ObjectIdentifier($0)).inserted
        }
    }

    /// Activates the toggle at `index` among `switches()`.
    @discardableResult
    func toggleSwitch(
        at index: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let all = switches()
        guard index < all.count else {
            XCTFail("No switch at \(index). Found \(all.count)", file: file, line: line)
            return false
        }
        let handled = all[index].accessibilityActivate()
        pump()
        return handled
    }

    /// Moves the first slider on screen to `fraction` of its track, as a
    /// drag would.
    func slide(toFraction fraction: Float) {
        guard let slider = firstView(of: UISlider.self) else {
            XCTFail("No slider")
            return
        }
        slider.value = slider.minimumValue
            + (slider.maximumValue - slider.minimumValue) * fraction
        slider.sendActions(for: .valueChanged)
        pump(0.2)
    }

    /// The first view of type `T` anywhere under the window or presented
    /// controllers.
    func firstView<T: UIView>(of type: T.Type) -> T? {
        var roots: [UIView] = [window]
        var presented = controller.presentedViewController
        while let next = presented {
            roots.append(next.view)
            presented = next.presentedViewController
        }
        for root in roots {
            if let match = Self.find(T.self, in: root) {
                return match
            }
        }
        return nil
    }

    /// Every view of type `T` under the window or presented controllers, in
    /// layout order.
    func allViews<T: UIView>(of type: T.Type) -> [T] {
        var roots: [UIView] = [window]
        var presented = controller.presentedViewController
        while let next = presented {
            roots.append(next.view)
            presented = next.presentedViewController
        }
        return roots.flatMap { Self.findAll(T.self, in: $0) }
    }

    private static func findAll<T: UIView>(_ type: T.Type, in view: UIView) -> [T] {
        (view as? T).map { [$0] } ?? view.subviews.flatMap { findAll(type, in: $0) }
    }

    private static func find<T: UIView>(_ type: T.Type, in view: UIView) -> T? {
        if let match = view as? T {
            return match
        }
        for subview in view.subviews {
            if let match = find(type, in: subview) {
                return match
            }
        }
        return nil
    }

    /// Selects the tab titled `title` the way a tap on the tab bar would.
    /// SwiftUI backs `TabView` with `viewControllers` up to iOS 26 and with
    /// `UITab`s from iOS 27, so both paths are supported.
    func selectTabBarItem(_ title: String) {
        guard let tabBarController = Self.findTabBarController(in: controller) else {
            XCTFail("No tab bar")
            return
        }
        let delegate = tabBarController.delegate

        if let index = tabBarController.tabBar.items?.firstIndex(where: { $0.title == title }),
           let target = tabBarController.viewControllers?[index] {
            guard delegate?.tabBarController?(tabBarController, shouldSelect: target) ?? true else {
                return
            }
            tabBarController.selectedViewController = target
            delegate?.tabBarController?(tabBarController, didSelect: target)
        } else if #available(iOS 18, *),
                  let tab = tabBarController.tabs.first(where: { $0.title == title }) {
            let previous = tabBarController.selectedTab
            guard delegate?.tabBarController?(tabBarController, shouldSelectTab: tab) ?? true else {
                return
            }
            tabBarController.selectedTab = tab
            delegate?.tabBarController?(tabBarController, didSelectTab: tab, previousTab: previous)
        } else {
            XCTFail("No tab titled \(title)")
            return
        }
        pump(0.3)
    }

    private static func findTabBarController(
        in viewController: UIViewController
    ) -> UITabBarController? {
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        for child in viewController.children {
            if let match = findTabBarController(in: child) {
                return match
            }
        }
        return nil
    }

    /// Selects the first list row (UICollectionView cell) whose
    /// accessibility label contains `text`, as a tap on the row would.
    func selectListRow(_ text: String) {
        var collectionViews: [UICollectionView] = []
        func gather(_ view: UIView) {
            if let collectionView = view as? UICollectionView {
                collectionViews.append(collectionView)
            }
            view.subviews.forEach(gather)
        }
        gather(window)
        for collectionView in collectionViews {
            for indexPath in collectionView.indexPathsForVisibleItems.sorted() {
                guard let cell = collectionView.cellForItem(at: indexPath) else { continue }
                let labels = ViewHost.labels(in: cell)
                guard labels.contains(where: { $0.contains(text) }) else { continue }
                let delegate = collectionView.delegate
                if delegate?.collectionView?(collectionView, shouldSelectItemAt: indexPath) ?? true {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
                }
                pump(0.4)
                return
            }
        }
        XCTFail("No list row containing \(text)")
    }

    private static func labels(in object: NSObject, depth: Int = 0) -> [String] {
        guard depth < 30 else { return [] }
        var result: [String] = []
        if let label = object.accessibilityLabel {
            result.append(label)
        }
        if let elements = object.accessibilityElements as? [NSObject] {
            for element in elements {
                result += labels(in: element, depth: depth + 1)
            }
        }
        if let view = object as? UIView {
            for subview in view.subviews {
                result += labels(in: subview, depth: depth + 1)
            }
        }
        return result
    }

    /// Runs the action of the alert button titled `title`, as a tap would.
    func tapAlertButton(
        _ title: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var presented = controller.presentedViewController
        while let current = presented {
            if let alert = current as? UIAlertController,
               let action = alert.actions.first(where: { $0.title == title }) {
                typealias Handler = @convention(block) (UIAlertAction) -> Void
                if let block = action.value(forKey: "handler") as AnyObject? {
                    unsafeBitCast(block, to: Handler.self)(action)
                }
                pump(0.4)
                if alert.presentingViewController != nil {
                    alert.dismiss(animated: false)
                    pump(0.2)
                }
                return
            }
            presented = current.presentedViewController
        }
        XCTFail("No alert button \(title)", file: file, line: line)
    }

    /// Triggers pull-to-refresh on the first refreshable scroll view.
    func pullToRefresh() {
        guard let refreshControl = firstView(of: UIRefreshControl.self) else {
            XCTFail("No refresh control")
            return
        }
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
        pump(0.3)
    }

    /// Types `text` into the search bar the way a user would.
    func search(_ text: String) {
        guard let searchBar = firstView(of: UISearchBar.self) else {
            XCTFail("No search bar")
            return
        }
        searchBar.text = text
        searchBar.delegate?.searchBar?(searchBar, textDidChange: text)
        pump(0.2)
    }

    /// Moves the window into the app's window scene so code that looks up
    /// the key window of the connected scene finds this one.
    func attachToScene() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            return
        }
        window.windowScene = scene
        window.makeKeyAndVisible()
        pump()
    }

    /// Dismisses whatever controller is presented, as a swipe-down would.
    func dismissPresented() {
        controller.dismiss(animated: false)
        pump(0.3)
    }

    /// Removes the content from the window so `onDisappear` runs.
    func tearDown() {
        window.isHidden = true
        window.rootViewController = nil
        pump()
    }
}
