//
//  HidayahAppWidgetBundle.swift
//  hidayah-app-widget
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import WidgetKit
import SwiftUI

@main
struct HidayahAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        TrackerWidget()
        QuickSurahWidget()
    }
}
