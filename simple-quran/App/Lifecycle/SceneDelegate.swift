//
//  SceneDelegate.swift
//  simple-quran
//

import SwiftUI
import UIKit
import UserNotifications

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appController: AppController? {
        (UIApplication.shared.delegate as? AppDelegate)?.appController
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
              let appController else {
            return
        }

        let rootView = RootView(
            surahService: appController.surahService,
            taskManager: appController.taskManager,
            router: appController.router
        )
        .onOpenURL { url in
            _ = appController.deeplinkManager.handleDeepLink(url: url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            guard let url = userActivity.webpageURL else { return }
            _ = appController.deeplinkManager.handleDeepLink(url: url)
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()

        TaskManager.shared.loadTasks()
        Task {
            try? await UNUserNotificationCenter.current().setBadgeCount(0)
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            appController.handleShortcut(shortcutItem)
        }

        for urlContext in connectionOptions.urlContexts {
            _ = appController.deeplinkManager.handleDeepLink(
                url: urlContext.url
            )
        }

        appController.applyPendingShortcutIfNeeded()
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        appController?.handleShortcut(shortcutItem)
        appController?.applyPendingShortcutIfNeeded()
        completionHandler(true)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let appController else { return }

        for context in URLContexts {
            _ = appController.deeplinkManager.handleDeepLink(
                url: context.url
            )
        }
    }

    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              let appController else {
            return
        }

        _ = appController.deeplinkManager.handleDeepLink(url: url)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        TaskManager.shared.loadTasks()
        appController?.applyPendingShortcutIfNeeded()

        Task {
            try? await UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }
}
