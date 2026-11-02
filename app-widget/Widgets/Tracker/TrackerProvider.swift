//
//  TrackerProvider.swift
//  app-widgetExtension
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import AppIntents
import WidgetKit
import SwiftUI

struct TrackerProvider: TimelineProvider {
    @AppStorage(
        Storage.StorageKey.widgetContext.rawValue,
        store: Storage.userDefaults
    ) var widgetContext = Data()

    func placeholder(in context: Context) -> TrackerEntry {
        TrackerEntry(
            date: Date(),
            progress: 0.65,
            completedTasks: 15,
            totalTasks: 23,
            upcomingTasks: [
                TaskDetails(name: "Dawn Alms (Sodaqah)", category: .default(.fajr)),
                TaskDetails(name: "Solawat 10x", category: .default(.fajr)),
                TaskDetails(name: "Recitation of Ayatul Qursi 1x", category: .default(.fajr)),
                TaskDetails(name: "Do'a to parents", category: .default(.fajr)),
                TaskDetails(name: "Qabliah Fajr", category: .default(.fajr)),
                TaskDetails(name: "Fajr prayer", category: .default(.fajr)),
                TaskDetails(name: "Istighfar 3x", category: .default(.fajr)),
                TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.fajr)),
                TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.fajr)),
                TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.fajr))
            ]
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (TrackerEntry) -> ()
    ) {
        let entry = TrackerEntry(
            date: Date(),
            progress: 0.65,
            completedTasks: 15,
            totalTasks: 23,
            upcomingTasks: [
                TaskDetails(name: "Dawn Alms (Sodaqah)", category: .default(.fajr)),
                TaskDetails(name: "Solawat 10x", category: .default(.fajr)),
                TaskDetails(name: "Recitation of Ayatul Qursi 1x", category: .default(.fajr)),
                TaskDetails(name: "Do'a to parents", category: .default(.fajr)),
                TaskDetails(name: "Qabliah Fajr", category: .default(.fajr)),
                TaskDetails(name: "Fajr prayer", category: .default(.fajr)),
                TaskDetails(name: "Istighfar 3x", category: .default(.fajr)),
                TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.fajr)),
                TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.fajr)),
                TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.fajr))
            ]
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TrackerEntry>) -> ()
    ) {
        let widgetContext: WidgetContext? = Storage.loadObject(
            key: .widgetContext
        )
        let entry = TrackerEntry(
            date: Date(),
            progress: widgetContext?.progress ?? 0,
            completedTasks: widgetContext?.completedTasks ?? 0,
            totalTasks: widgetContext?.totalTasks ?? 1,
            upcomingTasks: widgetContext?.upcomingTasks ?? []
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(60 * 15))
        )
        completion(timeline)
    }
}

struct TrackerEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let completedTasks: Int
    let totalTasks: Int
    let upcomingTasks: [TaskDetails]
}
