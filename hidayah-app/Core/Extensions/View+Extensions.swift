//
//  View+Extensions.swift
//  hidayah-app
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
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
