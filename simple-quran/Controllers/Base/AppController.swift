//
//  AppController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import Foundation
import SwiftUI
import UIKit
import UserNotifications
import FirebaseCore

class AppController: NSObject {
    let apiClientService = APIClientService()
    lazy var surahService = SurahService(
        apiClientService: apiClientService
    )
    let router = AppRouter()
    lazy var deeplinkManager = DeeplinkManager(
        router: router
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
}

extension AppController {
    private func configureCustomFont() {
        Font.loadFontsBundle(bundle: "Fonts", fontExtension: "ttf")
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
            DispatchQueue.main.async { [weak self] in
                _ = self?.deeplinkManager.handleDeepLink(url: url)
            }
        }
        if response.notification.request.identifier ==
            NotificationIdentifier.trackerProgressReset.rawValue {
            taskManager.resetDailyTasks()
        }
        completionHandler()
    }
}
