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
            with: window,
            deepLink: connectionOptions.urlContexts.first?.url
        )

        if let userActivity = connectionOptions.userActivities.first(where: {
            $0.activityType == NSUserActivityTypeBrowsingWeb
        }) {
            appDelegate.appController.scene(
                scene,
                continue: userActivity
            )
        }
    }

    func sceneDidDisconnect(
        _ scene: UIScene
    ) {
        window = nil
    }

    func sceneWillEnterForeground(
        _ scene: UIScene
    ) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        appDelegate.appController.scene(
            scene,
            openURLContexts: URLContexts
        )
    }

    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        appDelegate.appController.scene(
            scene,
            continue: userActivity
        )
    }
}
