//
//  HomePageContainerViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import RxSwift
import RxCocoa

class HomePageContainerViewController: UITabBarController, UITabBarControllerDelegate {
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListener()
    }
    
    private func setupView() {
        viewControllers = [
            createNavController(for: SurahListViewController<SurahListViewModel>(),
                                title: "Quran",
                                image: UIImage()),
            createNavController(for: SettingViewController<SettingViewModel>(),
                                title: "Setting",
                                image: UIImage()),
        ]
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
    }
    
    private func createNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        if #available(iOS 11.0, *) {
            navController.navigationBar.prefersLargeTitles = true
        }
        
        rootViewController.navigationItem.title = title
        
        return navController
    }
}
