//
//  RootViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/31/24.
//

import UIKit

class RootViewController: UITabBarController {

    private let surahService: SurahService

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    init(
        surahService: SurahService
    ) {
        self.surahService = surahService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let surahListViewController = SurahListViewController<SurahListViewModel>(
            surahService: surahService
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
            tag: 0
        )

        let bookmarkListViewController = BookmarkListViewController<BookmarkListViewModel>(
            surahService: surahService
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
            tag: 1
        )

        viewControllers = [
            surahListNavigationController,
            bookmarkListNavigationController
        ]

        tabBar.tintColor = .lightGreen
    }
}
