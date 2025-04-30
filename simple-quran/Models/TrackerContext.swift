//
//  TrackerContext.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import Foundation

struct TrackerContext: Codable {
    let tasks: [TaskDetails]
    let customCategories: [CustomCategory]
}
