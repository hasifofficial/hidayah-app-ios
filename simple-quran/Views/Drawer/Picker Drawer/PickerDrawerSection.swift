//
//  PickerDrawerSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import RxDataSources

enum PickerDrawerSection: SectionModelType {
    case title(item: SectionTitleTableViewCellViewModel?)
    case picker(item: PickerTableViewCellViewModel?)
    
    var items: [AnyObject] {
        switch self {
        case .title(let item):
            return item != nil ? [item!] : []
        case .picker(let item):
            return item != nil ? [item!] : []
        }
    }
    
    init(original: PickerDrawerSection, items: [AnyObject]) {
        switch original {
        case .title:
            self = .title(item: items.first as? SectionTitleTableViewCellViewModel)
        case .picker:
            self = .picker(item: items.first as? PickerTableViewCellViewModel)
        }
    }
}

extension PickerDrawerSection: TableViewDataSource {
    typealias Section = PickerDrawerSection
    
    static var allCases: [PickerDrawerSection] {
        return [
            .title(item: nil),
            .picker(item: nil)
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<PickerDrawerSection> {
        return RxTableViewSectionedReloadDataSource<PickerDrawerSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? SectionTitleTableViewCellViewModel {
                let newCell = tableView.dequeueCell(SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)

                cell = newCell
            } else if let viewModel = viewModel as? PickerTableViewCellViewModel {
                let newCell = tableView.dequeueCell(PickerTableViewCell<PickerTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                
                cell = newCell
            }
            
            return cell
        })
    }
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .title:
            return SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self
        case .picker:
            return PickerTableViewCell<PickerTableViewCellViewModel>.self
        }
    }
}

extension PickerDrawerSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .title:
            return 0
        case .picker:
            return 1
        }
    }
}
