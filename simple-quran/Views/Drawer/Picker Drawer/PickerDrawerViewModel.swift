//
//  PickerDrawerViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol PickerDrawerViewModelTypes: SectionSetter, TableViewSectionSetter where Section == PickerDrawerSection {
    var titleCell: BehaviorRelay<SectionTitleTableViewCellViewModel?> { get }
    var pickerCell: BehaviorRelay<PickerTableViewCellViewModel?> { get }
    var selectedItem: BehaviorRelay<PickerItemSelectorObj?> { get }
    var doneButtonTapHandler: BehaviorRelay<(() -> Void)?> { get }

    init()
}

class PickerDrawerViewModel: PickerDrawerViewModelTypes {
    let titleCell = BehaviorRelay<SectionTitleTableViewCellViewModel?>(value: nil)
    let pickerCell = BehaviorRelay<PickerTableViewCellViewModel?>(value: nil)
    let selectedItem = BehaviorRelay<PickerItemSelectorObj?>(value: nil)
    let doneButtonTapHandler = BehaviorRelay<(() -> Void)?>(value: nil)
        
    var dataSource: RxTableViewSectionedReloadDataSource<Section> = Section.generateDataSource()
    var sectionCache = [Int: PickerDrawerSection]()
    private(set) public var sectionedItems: BehaviorRelay<[PickerDrawerSection]> = BehaviorRelay(value: [])
    
    required init() {
        
    }
    
    convenience init(title: String, items: [PickerItemSelectorObj]) {
        self.init()
        
        let titleVM = SectionTitleTableViewCellViewModel()
        titleVM.titleLabelText.accept(title)
        titleVM.titleLabelTextFont.accept(.systemFont(ofSize: 22, weight: .bold))
        titleVM.titleLabelTextAlignment.accept(.center)
        
        let pickerVM = PickerTableViewCellViewModel()
        pickerVM.items.accept(items)

        if let firstItem = items.first {
            selectedItem.accept(firstItem)
        }

        titleCell.accept(titleVM)
        pickerCell.accept(pickerVM)
    }
}
