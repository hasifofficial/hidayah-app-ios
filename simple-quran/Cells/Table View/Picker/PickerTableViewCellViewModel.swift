//
//  PickerTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit
import Combine

protocol PickerTableViewCellViewModelTypes {
    var pickerLabelFont: CurrentValueSubject<UIFont, Never> { get }

    var numberOfComponent: CurrentValueSubject<Int, Never> { get }
    var items: CurrentValueSubject<[PickerItemSelectorObj], Never> { get }
    var selectedItem: CurrentValueSubject<PickerItemSelectorObj?, Never> { get }
    
    var initialRow: CurrentValueSubject<Int, Never> { get }
    var selectedRow: CurrentValueSubject<Int, Never> { get }
    
    init()
}

class PickerTableViewCellViewModel: PickerTableViewCellViewModelTypes {
    let pickerLabelFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 16, weight: .bold))

    let numberOfComponent = CurrentValueSubject<Int, Never>(1)
    let items = CurrentValueSubject<[PickerItemSelectorObj], Never>([PickerItemSelectorObj]())
    let selectedItem = CurrentValueSubject<PickerItemSelectorObj?, Never>(nil)
    
    let initialRow = CurrentValueSubject<Int, Never>(0)
    let selectedRow = CurrentValueSubject<Int, Never>(0)
    
    required init() {
        
    }
}
