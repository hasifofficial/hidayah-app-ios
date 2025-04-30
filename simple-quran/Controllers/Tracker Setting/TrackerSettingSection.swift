//
//  TrackerSettingSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/2/25.
//

import RxDataSources

enum TrackerSettingSection: SectionModelType {
    case trackerHistoryTitle(item: SectionTitleTableViewCellViewModel?)
    case trackerHistory(item: SectionTitleTableViewCellViewModel?)
    case categoryTitle(item: SectionTitleTableViewCellViewModel?)
    case manageCategory(item: SectionTitleTableViewCellViewModel?)
    case resetDailyProgress(item: SectionTitleTableViewCellViewModel?)
    case resetAll(item: SectionTitleTableViewCellViewModel?)

    var items: [AnyObject] {
        switch self {
        case .trackerHistoryTitle(let item):
            return item != nil ? [item!] : []
        case .trackerHistory(let item):
            return item != nil ? [item!] : []
        case .categoryTitle(let item):
            return item != nil ? [item!] : []
        case .manageCategory(let item):
            return item != nil ? [item!] : []
        case .resetDailyProgress(let item):
            return item != nil ? [item!] : []
        case .resetAll(let item):
            return item != nil ? [item!] : []
        }
    }
    
    init(original: TrackerSettingSection, items: [AnyObject]) {
        switch original {
        case .trackerHistoryTitle:
            self = .trackerHistoryTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .trackerHistory:
            self = .trackerHistory(item: items.first as? SectionTitleTableViewCellViewModel)
        case .categoryTitle:
            self = .categoryTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .manageCategory:
            self = .manageCategory(item: items.first as? SectionTitleTableViewCellViewModel)
        case .resetDailyProgress:
            self = .resetDailyProgress(item: items.first as? SectionTitleTableViewCellViewModel)
        case .resetAll:
            self = .resetAll(item: items.first as? SectionTitleTableViewCellViewModel)
        }
    }
}

extension TrackerSettingSection: TableViewDataSource {
    typealias Section = TrackerSettingSection
    
    static var allCases: [TrackerSettingSection] {
        return [
            .trackerHistoryTitle(item: SectionTitleTableViewCellViewModel()),
            .trackerHistory(item: SectionTitleTableViewCellViewModel()),
            .categoryTitle(item: SectionTitleTableViewCellViewModel()),
            .manageCategory(item: SectionTitleTableViewCellViewModel()),
            .resetDailyProgress(item: SectionTitleTableViewCellViewModel()),
            .resetAll(item: SectionTitleTableViewCellViewModel()),
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<TrackerSettingSection> {
        return RxTableViewSectionedReloadDataSource<TrackerSettingSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? SectionTitleTableViewCellViewModel {
                let newCell = tableView.dequeueCell(SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            }
            
            return cell
        })
    }
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .trackerHistoryTitle, .trackerHistory, .categoryTitle, .manageCategory, .resetDailyProgress, .resetAll:
            return SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self
        }
    }
}

extension TrackerSettingSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .trackerHistoryTitle:
            return 0
        case .trackerHistory:
            return 0
        case .categoryTitle:
            return 0
        case .manageCategory:
            return 1
        case .resetDailyProgress:
            return 2
        case .resetAll:
            return 3
        }
    }
}
