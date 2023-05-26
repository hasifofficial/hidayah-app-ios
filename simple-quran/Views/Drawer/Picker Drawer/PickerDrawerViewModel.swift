//
//  PickerDrawerViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol PickerDrawerViewModelTypes: SectionSetter, TableViewSectionSetter where Section == PickerDrawerSection {
    var titleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> { get }
    var pickerCell: CurrentValueSubject<PickerTableViewCellViewModel?, Never> { get }
    var selectedItem: CurrentValueSubject<PickerItemSelectorObj?, Never> { get }
    var doneButtonTapHandler: CurrentValueSubject<(() -> Void)?, Never> { get }

    init()
}

class PickerDrawerViewModel: PickerDrawerViewModelTypes {
    let titleCell = CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(nil)
    let pickerCell = CurrentValueSubject<PickerTableViewCellViewModel?, Never>(nil)
    let selectedItem = CurrentValueSubject<PickerItemSelectorObj?, Never>(nil)
    let doneButtonTapHandler = CurrentValueSubject<(() -> Void)?, Never>(nil)
        
    var dataSource: RxTableViewSectionedReloadDataSource<Section> = Section.generateDataSource()
    var sectionCache = [Int: PickerDrawerSection]()
    private(set) public var sectionedItems: BehaviorRelay<[PickerDrawerSection]> = BehaviorRelay(value: [])
    
    required init() {
        
    }
    
    convenience init(title: String, items: [PickerItemSelectorObj]) {
        self.init()
        
        let titleVM = SectionTitleTableViewCellViewModel()
        titleVM.titleLabelText.send(title)
        titleVM.titleLabelTextFont.send(.systemFont(ofSize: 22, weight: .bold))
        titleVM.titleLabelTextAlignment.send(.center)
        
        let pickerVM = PickerTableViewCellViewModel()
        pickerVM.items.send(items)

        if let firstItem = items.first {
            selectedItem.send(firstItem)
        }

        titleCell.send(titleVM)
        pickerCell.send(pickerVM)
    }
}
