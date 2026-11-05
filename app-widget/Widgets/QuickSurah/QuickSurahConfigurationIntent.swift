//
//  QuickSurahConfigurationIntent.swift
//  app-widget
//

import AppIntents
import WidgetKit

// MARK: - Configuration

struct QuickSurahConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "widget_quick_access_display_name"
    static let description = IntentDescription(
        LocalizedStringResource("widget_quick_access_configuration_description")
    )

    @Parameter(title: LocalizedStringResource("widget_quick_access_surahs_parameter"))
    var surahs: [QuickSurahEntity]?

    init() {}
}
