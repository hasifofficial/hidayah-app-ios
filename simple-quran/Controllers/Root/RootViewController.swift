//
//  RootViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/31/24.
//

import UIKit
import SwiftUI

class RootViewController: UITabBarController {
    private let surahService: SurahService
    private let taskManager: TaskManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    init(
        surahService: SurahService,
        taskManager: TaskManager
    ) {
        self.surahService = surahService
        self.taskManager = taskManager

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .onScrollDown
        }
        
        let surahListViewController = SurahListViewController<SurahListViewModel>(
            surahService: surahService,
            taskManager: taskManager
        )
        
        let surahListNavigationController = UINavigationController(
            rootViewController: surahListViewController
        )
        surahListNavigationController.navigationBar.prefersLargeTitles = true
        surahListNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                "surah_list_header_title",
                comment: ""
            ),
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )

        let bookmarkListViewController = BookmarkListViewController<BookmarkListViewModel>(
            surahService: surahService,
            taskManager: taskManager
        )
        let bookmarkListNavigationController = UINavigationController(
            rootViewController: bookmarkListViewController
        )
        bookmarkListNavigationController.navigationBar.prefersLargeTitles = true
        bookmarkListNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                "bookmark_list_header_title",
                comment: ""
            ),
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        let trackerListView = TrackerListView(
            surahService: surahService,
            taskManager: taskManager
        )
        let trackerListHostingController = UIHostingController(
            rootView: trackerListView
        )
        trackerListHostingController.navigationController?.navigationBar.tintColor = .lightGreen
        trackerListHostingController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                "tracker_list_tab_bar_title",
                comment: ""
            ),
            image: UIImage(systemName: "checklist.unchecked"),
            selectedImage: UIImage(systemName: "checklist.checked")
        )
        
        let searchViewController = SearchViewController<SearchViewModel>(
            surahService: surahService,
            taskManager: taskManager
        )        
        let searchNavigationController = UINavigationController(
            rootViewController: searchViewController
        )
        searchNavigationController.navigationBar.prefersLargeTitles = true
        searchNavigationController.tabBarItem = UITabBarItem(
            tabBarSystemItem: .search,
            tag: 3
        )

        viewControllers = [
            surahListNavigationController,
            bookmarkListNavigationController,
            trackerListHostingController,
            searchNavigationController
        ]

        tabBar.tintColor = .lightGreen
    }
}
