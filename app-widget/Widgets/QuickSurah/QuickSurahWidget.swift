//
//  QuickSurahWidget.swift
//  app-widget
//

import SwiftUI
import WidgetKit

struct QuickSurahWidget: Widget {
    let kind = "QuickSurahWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: QuickSurahConfigurationIntent.self,
            provider: QuickSurahProvider(),
            content: Self.entryView
        )
        .configurationDisplayName(
            LocalizedStringResource("widget_quick_access_display_name")
        )
        .description(
            LocalizedStringResource("widget_quick_access_description")
        )
        .supportedFamilies([.systemMedium])
    }

    static func entryView(for entry: QuickSurahEntry) -> QuickSurahWidgetEntryView {
        QuickSurahWidgetEntryView(entry: entry)
    }
}
