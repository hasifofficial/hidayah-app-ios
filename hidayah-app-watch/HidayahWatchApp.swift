//
//  HidayahWatchApp.swift
//  hidayah-app-watch
//

import SwiftUI

@main
struct HidayahWatchApp: App {
    @State private var trackerModel: WatchTrackerModel
    @State private var rakaatModel: WatchRakaatModel
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let trackerModel = WatchTrackerModel()
        _trackerModel = State(initialValue: trackerModel)
        _rakaatModel = State(initialValue: WatchRakaatModel(link: trackerModel))
    }

    var body: some Scene {
        WindowGroup {
            WatchRootView(trackerModel: trackerModel, rakaatModel: rakaatModel)
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
