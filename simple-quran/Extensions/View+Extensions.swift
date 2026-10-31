//
//  View+Extensions.swift
//  simple-quran
//

import SwiftUI

extension View {
    func settingsListRow() -> some View {
        self
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
