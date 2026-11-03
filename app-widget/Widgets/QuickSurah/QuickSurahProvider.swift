//
//  QuickSurahProvider.swift
//  app-widget
//

import AppIntents
import WidgetKit

// MARK: - Timeline

struct QuickSurahEntry: TimelineEntry {
    let date: Date
    let surahs: [QuickSurahEntity]
}

struct QuickSurahProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> QuickSurahEntry {
        Self.placeholderEntry(date: Date())
    }

    func snapshot(
        for configuration: QuickSurahConfigurationIntent,
        in context: Context
    ) async -> QuickSurahEntry {
        Self.entry(for: configuration, date: Date())
    }

    func timeline(
        for configuration: QuickSurahConfigurationIntent,
        in context: Context
    ) async -> Timeline<QuickSurahEntry> {
        Self.timeline(for: configuration, date: Date())
    }

    static func placeholderEntry(date: Date) -> QuickSurahEntry {
        QuickSurahEntry(date: date, surahs: QuickSurahCatalog.quickAccess)
    }

    static func entry(
        for configuration: QuickSurahConfigurationIntent,
        date: Date
    ) -> QuickSurahEntry {
        QuickSurahEntry(
            date: date,
            surahs: selectedSurahs(from: configuration)
        )
    }

    static func timeline(
        for configuration: QuickSurahConfigurationIntent,
        date: Date
    ) -> Timeline<QuickSurahEntry> {
        Timeline(
            entries: [
                entry(for: configuration, date: date)
            ],
            policy: .never
        )
    }

    static func selectedSurahs(
        from configuration: QuickSurahConfigurationIntent
    ) -> [QuickSurahEntity] {
        let selected = Array((configuration.surahs ?? []).prefix(3))
        return selected.isEmpty ? QuickSurahCatalog.quickAccess : selected
    }
}
