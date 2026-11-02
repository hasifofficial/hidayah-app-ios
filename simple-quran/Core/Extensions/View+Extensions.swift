//
//  View+Extensions.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
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
