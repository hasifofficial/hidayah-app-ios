//
//  AppDelegate.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let appController = AppController()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.registerForRemoteNotifications()

        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
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

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        appController.application(
            app,
            open: url,
            options: options
        )
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        appController.application(
            application,
            continue: userActivity,
            restorationHandler: restorationHandler
        )
    }
}
