//
//  TaskDetails.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import Foundation

struct TaskDetails: Identifiable, Codable {
    let id: UUID
    var name: String
    var isCompleted: Bool
    var category: Category
    
    init(
        id: UUID = UUID(),
        name: String,
        category: Category,
        isCompleted: Bool = false,
    ) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.category = category
    }
}
