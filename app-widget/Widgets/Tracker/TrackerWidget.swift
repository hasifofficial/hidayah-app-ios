//
//  TrackerWidget.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI
import WidgetKit

struct TrackerWidget: Widget {
    let kind: String = "TrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TrackerProvider()
        ) { entry in
            TrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(
            LocalizedStringResource("widget_configuration_title")
        )
        .description(
            LocalizedStringResource("widget_configuration_description")
        )
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
