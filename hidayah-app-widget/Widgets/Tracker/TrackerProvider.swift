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
        Self.sampleEntry(date: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (TrackerEntry) -> ()
    ) {
        completion(Self.sampleEntry(date: Date()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TrackerEntry>) -> ()
    ) {
        completion(
            Self.timeline(
                for: Storage.loadObject(key: .widgetContext),
                now: Date()
            )
        )
    }

    /// The sample shown in the widget gallery and as a placeholder.
    static func sampleEntry(date: Date) -> TrackerEntry {
        TrackerEntry(
            date: date,
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

    static func timeline(
        for widgetContext: WidgetContext?,
        now: Date
    ) -> Timeline<TrackerEntry> {
        var entries = [
            entry(for: widgetContext, on: now)
        ]

        // Reset the widget when the tracker starts its next day.
        if let nextDayStart = TrackerDayKey.nextDayStart(after: now) {
            entries.append(
                entry(for: widgetContext, on: nextDayStart)
            )
        }

        return Timeline(
            entries: entries,
            policy: .after(now.addingTimeInterval(60 * 15))
        )
    }

    static func entry(
        for widgetContext: WidgetContext?,
        on date: Date
    ) -> TrackerEntry {
        // The app only rolls the tracker over when it runs, so a snapshot
        // from an earlier day is shown the way the app will reset it.
        if let widgetContext,
           let dayKey = widgetContext.dayKey,
           dayKey < TrackerDayKey.today(now: date) {
            return TrackerEntry(
                date: date,
                progress: 0,
                completedTasks: 0,
                totalTasks: widgetContext.totalTasks,
                upcomingTasks: widgetContext.resetUpcomingTasks ?? []
            )
        }

        return TrackerEntry(
            date: date,
            progress: widgetContext?.progress ?? 0,
            completedTasks: widgetContext?.completedTasks ?? 0,
            totalTasks: widgetContext?.totalTasks ?? 1,
            upcomingTasks: widgetContext?.upcomingTasks ?? []
        )
    }
}

struct TrackerEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let completedTasks: Int
    let totalTasks: Int
    let upcomingTasks: [TaskDetails]
}
