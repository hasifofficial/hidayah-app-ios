//
//  PickerItemSelectorObj.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import Foundation

class PickerItemSelectorObj: Hashable {
    static func == (lhs: PickerItemSelectorObj, rhs: PickerItemSelectorObj) -> Bool {
        return lhs.value == rhs.value && lhs.title == rhs.title
    }
    
    let title: String
    let value: String
    let item: Any?
    
    init(title: String, value: String, item: Any? = nil) {
        self.title = title
        self.value = value
        self.item = item
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(value)
    }
}
