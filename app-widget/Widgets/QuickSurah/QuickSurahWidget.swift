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
            provider: QuickSurahProvider()
        ) { entry in
            QuickSurahWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(
            LocalizedStringResource("widget_quick_access_display_name")
        )
        .description(
            LocalizedStringResource("widget_quick_access_description")
        )
        .supportedFamilies([.systemMedium])
    }
}
