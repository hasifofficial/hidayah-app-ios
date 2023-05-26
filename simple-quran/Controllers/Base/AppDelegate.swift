//
//  AppDelegate.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let appController = AppController()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(
            frame: UIScreen.main.bounds
        )
        window.makeKeyAndVisible()
        self.window = window

        application.registerForRemoteNotifications()

        appController.start(
            with: window
        )

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        appController.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        appController.application(
            application,
            didFailToRegisterForRemoteNotificationsWithError: error
        )
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        appController.application(
            application,
            didReceiveRemoteNotification: userInfo,
            fetchCompletionHandler: completionHandler
        )
    }

    func applicationWillResignActive(
        _ application: UIApplication
    ) {
        appController.applicationWillResignActive(application)
    }

    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {
        appController.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(
        _ application: UIApplication
    ) {
        appController.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        appController.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(
        _ application: UIApplication
    ) {
        appController.applicationWillTerminate(application)
    }
}
