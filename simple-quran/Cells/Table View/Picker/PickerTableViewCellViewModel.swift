//
//  PickerTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import RxSwift
import RxCocoa

protocol PickerTableViewCellViewModelTypes {
    var pickerLabelFont: BehaviorRelay<UIFont> { get }

    var numberOfComponent: BehaviorRelay<Int> { get }
    var items: BehaviorRelay<[PickerItemSelectorObj]> { get }
    var selectedItem: BehaviorRelay<PickerItemSelectorObj?> { get }
    
    var initialRow: BehaviorRelay<Int> { get }
    var selectedRow: BehaviorRelay<Int> { get }
    
    init()
}

class PickerTableViewCellViewModel: PickerTableViewCellViewModelTypes {
    let pickerLabelFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 16, weight: .bold))

    let numberOfComponent = BehaviorRelay(value: 1)
    let items = BehaviorRelay<[PickerItemSelectorObj]>(value: [PickerItemSelectorObj]())
    let selectedItem = BehaviorRelay<PickerItemSelectorObj?>(value: nil)
    
    let initialRow = BehaviorRelay(value: 0)
    let selectedRow = BehaviorRelay(value: 0)
    
    required init() {
        
    }
}
