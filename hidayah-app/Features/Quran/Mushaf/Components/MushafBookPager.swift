//
//  MushafBookPager.swift
//  simple-quran
//

import SwiftUI
import UIKit

/// Wide-screen spreads that turn like the leaves of a printed book: drag a
/// page's outer edge across and it curls over the spine, its back showing
/// the next page.
///
/// A Mushaf opens from the right, so reading on turns the left page over to
/// the right. UIKit's page curl reads left to right, so the pages run in
/// reverse: what it calls the page "before" is the next page to read.
struct MushafBookPager: UIViewControllerRepresentable {
    let layout: MushafLayout
    /// The first (right) page of the spread to show.
    let spreadStart: Int
    /// Both pages together.
    let bookSize: CGSize
    let displayScale: CGFloat
    let viewModel: MushafViewModel

    static let cornerRadius: CGFloat = 12

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [.spineLocation: NSNumber(value: UIPageViewController.SpineLocation.mid.rawValue)]
        )
        controller.isDoubleSided = true
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.view.backgroundColor = .clear
        // The page order above is physical, whatever the app's language.
        controller.view.semanticContentAttribute = .forceLeftToRight
        // A tap shows or hides the floating bar, as on a single page; pages
        // turn by dragging.
        for recognizer in controller.gestureRecognizers where recognizer is UITapGestureRecognizer {
            recognizer.isEnabled = false
        }

        let layer = controller.view.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        context.coordinator.show(spreadStart, in: controller)
        updateShadow(of: controller)
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        updateShadow(of: controller)

        if coordinator.displayedStart != spreadStart, !coordinator.isTurning {
            // A jump from the navigator, or the place kept from one page.
            coordinator.show(spreadStart, in: controller)
        } else {
            // Same spread; the size or the page count may have changed.
            for case let page as PageController in controller.viewControllers ?? [] {
                page.rootView = coordinator.pageView(page.page)
            }
        }
    }

    private func updateShadow(of controller: UIPageViewController) {
        controller.view.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: bookSize),
            cornerRadius: Self.cornerRadius
        ).cgPath
    }

    /// One page of the book, remembering which page it holds.
    final class PageController: UIHostingController<MushafBookPage> {
        let page: Int

        init(page: Int, rootView: MushafBookPage) {
            self.page = page
            super.init(rootView: rootView)
            safeAreaRegions = []
            view.backgroundColor = .clear
        }

        @available(*, unavailable)
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: MushafBookPager
        /// The right page of the spread on screen.
        private(set) var displayedStart: Int?
        /// While a leaf is mid-turn, the spread on screen belongs to the
        /// gesture.
        private(set) var isTurning = false

        init(_ parent: MushafBookPager) {
            self.parent = parent
        }

        /// A book with an odd page count ends on a blank left page, so the
        /// last leaf has a back.
        private var lastLeaf: Int {
            let count = parent.layout.pageCount
            return count.isMultiple(of: 2) ? count : count + 1
        }

        func pageView(_ page: Int) -> MushafBookPage {
            MushafBookPage(
                page: page,
                pageCount: parent.layout.pageCount,
                size: CGSize(width: parent.bookSize.width / 2, height: parent.bookSize.height),
                displayScale: parent.displayScale,
                viewModel: parent.viewModel
            )
        }

        private func controller(for page: Int) -> PageController {
            PageController(page: page, rootView: pageView(page))
        }

        /// Opens the book at the spread whose right page is `start`, without
        /// turning through the pages between.
        func show(_ start: Int, in pageViewController: UIPageViewController) {
            pageViewController.setViewControllers(
                [controller(for: start + 1), controller(for: start)],
                direction: .forward,
                animated: false
            )
            displayedStart = start
        }

        // MARK: Data source

        /// The next page to read.
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let page = (viewController as? PageController)?.page, page < lastLeaf else {
                return nil
            }
            return controller(for: page + 1)
        }

        /// The page read before.
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let page = (viewController as? PageController)?.page, page > 1 else {
                return nil
            }
            return controller(for: page - 1)
        }

        // MARK: Delegate

        func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]
        ) {
            isTurning = true
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            isTurning = false
            guard completed else { return }
            let pages = (pageViewController.viewControllers ?? []).compactMap { ($0 as? PageController)?.page }
            // The right page is the spread's first; it is always odd.
            guard let start = pages.first(where: { !$0.isMultiple(of: 2) }) else { return }
            displayedStart = start
            parent.viewModel.scrolledPage = start
        }
    }
}

/// One half of the open book: a framed page on its sheet of paper, the
/// spine shadow on the side facing the binding. Past the last page it is a
/// blank sheet.
struct MushafBookPage: View {
    let page: Int
    let pageCount: Int
    let size: CGSize
    let displayScale: CGFloat
    let viewModel: MushafViewModel

    /// Odd pages are right pages, bound on their left.
    private var spine: MushafFramedPage.Spine {
        page.isMultiple(of: 2) ? .right : .left
    }

    var body: some View {
        Group {
            if page <= pageCount {
                MushafFramedPage(
                    page: page,
                    size: size,
                    maxPixelWidth: size.width * displayScale,
                    spine: spine,
                    fillsSpace: true,
                    viewModel: viewModel
                )
            } else {
                Color.clear
                    .accessibilityHidden(true)
            }
        }
        .frame(width: size.width, height: size.height)
        .background {
            MushafPaperSheet(spine: spine, cornerRadius: MushafBookPager.cornerRadius)
        }
    }
}
