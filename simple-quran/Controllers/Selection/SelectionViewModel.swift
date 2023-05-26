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
    var itemsSubject = CurrentValueSubject<[ItemSelector], Never>([])
    var selectedItemSubject = CurrentValueSubject<ItemSelector?, Never>(nil)
    var errorSubject = PassthroughSubject<Error, Never>()

    let title: String
    private var cancellable = Set<AnyCancellable>()

    init(
        title: String,
        selectedItem: ItemSelector?,
        items: [ItemSelector]
    ) {
        self.title = title
        selectedItemSubject.send(selectedItem)
        itemsSubject.send(items)
    }
}
