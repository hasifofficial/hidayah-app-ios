//
//  HidayahApp.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import SwiftUI

@main
struct HidayahApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasLoadedTracker = false

    var body: some Scene {
        WindowGroup {
            RootView(
                surahService: appDelegate.appController.surahService,
                taskManager: appDelegate.appController.taskManager,
                router: appDelegate.appController.router
            )
            .onOpenURL { url in
                appDelegate.appController.deeplinkManager.handleDeepLink(url: url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else { return }

                appDelegate.appController.deeplinkManager.handleDeepLink(url: url)
            }
            .task {
                guard !hasLoadedTracker else { return }
                hasLoadedTracker = true

                TaskManager.shared.loadTasks()
                try? await UNUserNotificationCenter.current().setBadgeCount(0)
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active, hasLoadedTracker else { return }

                TaskManager.shared.loadTasks()
                Task {
                    try? await UNUserNotificationCenter.current().setBadgeCount(0)
                }
            }
        }
    }
}
