//
//  AppController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import Foundation
import UIKit
import UserNotifications
import Firebase

class AppController: NSObject {
    var window: UIWindow?
    let apiClientService = APIClientService()
    lazy var surahService = SurahService(
        apiClientService: apiClientService
    )
    lazy var deeplinkManager = DeeplinkManager(
        surahService: surahService
    )
    let taskManager = TaskManager.shared

    override init() {
        super.init()

        FirebaseApp.configure()
        self.configureCustomFont()
        self.scheduleKahfNotification()
        self.scheduleResetDailyTrackerNotification()

        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert,
            .sound,
            .badge,
            .carPlay
        ]) { (_, _) in }
        UNUserNotificationCenter.current().delegate = self
    }

    func start(
        with window: UIWindow,
        deepLink: URL? = nil
    ) {
        self.window = window
        let rootViewController = RootViewController(
            surahService: surahService,
            taskManager: taskManager
        )
        window.rootViewController = rootViewController
        if let deepLink = deepLink {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                _ = self.deeplinkManager.handleDeepLink(
                    url: deepLink
                )
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format:"%02.2hhx", $0) }.joined()

        #if DEBUG
        print("📣 Notification device token: \(token)")
        #endif
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        #if DEBUG
        print("Error register notification: \(error.localizedDescription)")
        #endif
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {

    }

    func applicationWillResignActive(
        _ application: UIApplication
    ) {

    }

    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {

    }

    func applicationWillEnterForeground(
        _ application: UIApplication
    ) {

    }

    func applicationDidBecomeActive(
        _ application: UIApplication
    ) {

    }

    func applicationWillTerminate(
        _ application: UIApplication
    ) {

    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        deeplinkManager.handleDeepLink(
            url: url
        )
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return false }

        return deeplinkManager.handleDeepLink(
            url: url
        )
    }
}

extension AppController {
    private func configureCustomFont() {
        UIFont.loadFontsBundle(bundle: "Fonts", fontExtension: "ttf")
    }

    private func scheduleKahfNotification() {
        let allowKahfReminder = Storage.load(key: .allowKahfReminder) as? Bool ?? true
        let identifier = NotificationIdentifier.kahfReminder.rawValue
        
        if allowKahfReminder {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString(
                "push_notification_kahf_reminder_title",
                comment: ""
            )
            content.body = NSLocalizedString(
                "push_notification_kahf_reminder_body",
                comment: ""
            )
            content.userInfo = [
                "url": "hidayahapp://inAppDeeplink/quran/18"
            ]
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar(identifier: .gregorian)
            dateComponents.weekday = 6
            dateComponents.hour = 9
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }

    private func scheduleResetDailyTrackerNotification() {
        let identifier = NotificationIdentifier.trackerProgressReset.rawValue

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(
            "push_notification_istiqamah_tracker_daily_reset_title",
            comment: ""
        )
        content.body = NSLocalizedString(
            "push_notification_istiqamah_tracker_daily_reset_body",
            comment: ""
        )
        content.userInfo = [
            "url": "hidayahapp://inAppDeeplink/tracker"
        ]
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension AppController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([
            .list,
            .banner,
            .sound
        ])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let urlString = userInfo["url"] as? String
        if let urlString = urlString,
           let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        if response.notification.request.identifier ==
            NotificationIdentifier.trackerProgressReset.rawValue {
            taskManager.resetDailyTasks()
        }
        completionHandler()
    }
}
