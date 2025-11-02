//
//  SceneDelegate.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/1/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(
            windowScene: windowScene
        )
        window.makeKeyAndVisible()
        self.window = window

        appDelegate.appController.start(
            with: window
        )
    }

    func sceneDidDisconnect(
        _ scene: UIScene
    ) {

    }

    func sceneDidBecomeActive(
        _ scene: UIScene
    ) {

    }

    func sceneWillResignActive(
        _ scene: UIScene
    ) {

    }

    func sceneWillEnterForeground(
        _ scene: UIScene
    ) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneDidEnterBackground(
        _ scene: UIScene
    ) {

    }
}
