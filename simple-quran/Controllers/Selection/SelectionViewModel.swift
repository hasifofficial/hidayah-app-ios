//
//  SelectionViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import Foundation
import Combine
import UIKit

class SelectionViewModel {
    var titleSubject = CurrentValueSubject<String?, Never>(nil)
    var itemsSubject = CurrentValueSubject<[ItemSelector], Never>([])
    var selectedItemSubject = CurrentValueSubject<ItemSelector?, Never>(nil)
    var errorSubject = PassthroughSubject<Error, Never>()

    init(
        title: String,
        items: [ItemSelector],
        selectedItem: ItemSelector?
    ) {
        titleSubject.send(title)
        itemsSubject.send(items)
        selectedItemSubject.send(selectedItem)
    }
}
