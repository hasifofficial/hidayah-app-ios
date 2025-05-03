//
//  Collection+Extension.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/3/25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
