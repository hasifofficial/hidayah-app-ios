//
//  SettingSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import RxDataSources

enum SettingSection: SectionModelType {
    case quranSettingTitle(item: SectionTitleTableViewCellViewModel?)
    case recitation(item: SectionTitleTableViewCellViewModel?)
    case translationLanguage(item: SectionTitleTableViewCellViewModel?)
    case notificationSettingTitle(item: SectionTitleTableViewCellViewModel?)
    case kahfReminder(item: SwitchTableViewCellViewModel?)
    case aboutTitle(item: SectionTitleTableViewCellViewModel?)
    case about(item: SectionTitleTableViewCellViewModel?)
    case privacy(item: SectionTitleTableViewCellViewModel?)
    case termCondition(item: SectionTitleTableViewCellViewModel?)
    case supportTitle(item: SectionTitleTableViewCellViewModel?)
    case feedback(item: SectionTitleTableViewCellViewModel?)

    var items: [AnyObject] {
        switch self {
        case .quranSettingTitle(let item):
            return item != nil ? [item!] : []
        case .recitation(let item):
            return item != nil ? [item!] : []
        case .translationLanguage(let item):
            return item != nil ? [item!] : []
        case .notificationSettingTitle(let item):
            return item != nil ? [item!] : []
        case .kahfReminder(let item):
            return item != nil ? [item!] : []
        case .aboutTitle(let item):
            return item != nil ? [item!] : []
        case .about(let item):
            return item != nil ? [item!] : []
        case .privacy(let item):
            return item != nil ? [item!] : []
        case .termCondition(let item):
            return item != nil ? [item!] : []
        case .supportTitle(let item):
            return item != nil ? [item!] : []
        case .feedback(let item):
            return item != nil ? [item!] : []
        }
    }
    
    init(original: SettingSection, items: [AnyObject]) {
        switch original {
        case .quranSettingTitle:
            self = .quranSettingTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .recitation:
            self = .recitation(item: items.first as? SectionTitleTableViewCellViewModel)
        case .translationLanguage:
            self = .translationLanguage(item: items.first as? SectionTitleTableViewCellViewModel)
        case .notificationSettingTitle:
            self = .notificationSettingTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .kahfReminder:
            self = .kahfReminder(item: items.first as? SwitchTableViewCellViewModel)
        case .aboutTitle:
            self = .aboutTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .about:
            self = .about(item: items.first as? SectionTitleTableViewCellViewModel)
        case .privacy:
            self = .privacy(item: items.first as? SectionTitleTableViewCellViewModel)
        case .termCondition:
            self = .termCondition(item: items.first as? SectionTitleTableViewCellViewModel)
        case .supportTitle:
            self = .supportTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .feedback:
            self = .feedback(item: items.first as? SectionTitleTableViewCellViewModel)
        }
    }
}

extension SettingSection: TableViewDataSource {
    typealias Section = SettingSection
    
    static var allCases: [SettingSection] {
        return [
            .quranSettingTitle(item: SectionTitleTableViewCellViewModel()),
            .recitation(item: SectionTitleTableViewCellViewModel()),
            .translationLanguage(item: SectionTitleTableViewCellViewModel()),
            .notificationSettingTitle(item: SectionTitleTableViewCellViewModel()),
            .kahfReminder(item: SwitchTableViewCellViewModel()),
            .aboutTitle(item: SectionTitleTableViewCellViewModel()),
            .about(item: SectionTitleTableViewCellViewModel()),
            .privacy(item: SectionTitleTableViewCellViewModel()),
            .termCondition(item: SectionTitleTableViewCellViewModel()),
            .supportTitle(item: SectionTitleTableViewCellViewModel()),
            .feedback(item: SectionTitleTableViewCellViewModel()),
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<SettingSection> {
        return RxTableViewSectionedReloadDataSource<SettingSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? SectionTitleTableViewCellViewModel {
                let newCell = tableView.dequeueCell(SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? SwitchTableViewCellViewModel {
                let newCell = tableView.dequeueCell(SwitchTableViewCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            }
            
            return cell
        })
    }
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .quranSettingTitle, .recitation, .translationLanguage, .notificationSettingTitle, .aboutTitle, .about, .privacy, .termCondition, .supportTitle, .feedback:
            return SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self
        case .kahfReminder:
            return SwitchTableViewCell.self
        }
    }
}

extension SettingSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .quranSettingTitle:
            return 0
        case .recitation:
            return 1
        case .translationLanguage:
            return 2
        case .notificationSettingTitle:
            return 3
        case .kahfReminder:
            return 4
        case .aboutTitle:
            return 5
        case .about:
            return 6
        case .privacy:
            return 7
        case .termCondition:
            return 8
        case .supportTitle:
            return 9
        case .feedback:
            return 10
        }
    }
}
