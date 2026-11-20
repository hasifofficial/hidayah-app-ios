//
//  Collection+Extensions.swift
//  hidayah-app
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
