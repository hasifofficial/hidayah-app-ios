//
//  HidayahWatchApp.swift
//  hidayah-app-watch
//

import SwiftUI

@main
struct HidayahWatchApp: App {
    @State private var trackerModel = WatchTrackerModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WatchRootView(trackerModel: trackerModel)
                .task {
                    trackerModel.activate()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        trackerModel.refresh()
                    }
                }
        }
    }
}
