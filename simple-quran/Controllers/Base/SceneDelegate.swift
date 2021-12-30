//
//  SceneDelegate.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = SurahListViewController<SurahListViewModel>()
//        let rootViewController = HomeViewController<HomeViewModel>()
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navController
                
        self.window = window
        
        window.makeKeyAndVisible()
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {

    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {

    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
