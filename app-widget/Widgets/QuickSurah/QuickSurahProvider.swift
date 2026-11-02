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
        QuickSurahEntry(date: Date(), surahs: QuickSurahCatalog.quickAccess)
    }

    func snapshot(
        for configuration: QuickSurahConfigurationIntent,
        in context: Context
    ) async -> QuickSurahEntry {
        QuickSurahEntry(
            date: Date(),
            surahs: selectedSurahs(from: configuration)
        )
    }

    func timeline(
        for configuration: QuickSurahConfigurationIntent,
        in context: Context
    ) async -> Timeline<QuickSurahEntry> {
        Timeline(
            entries: [
                QuickSurahEntry(
                    date: Date(),
                    surahs: selectedSurahs(from: configuration)
                )
            ],
            policy: .never
        )
    }

    private func selectedSurahs(
        from configuration: QuickSurahConfigurationIntent
    ) -> [QuickSurahEntity] {
        let selected = Array((configuration.surahs ?? []).prefix(3))
        return selected.isEmpty ? QuickSurahCatalog.quickAccess : selected
    }
}
