//
//  SurahDetailSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import RxDataSources

enum SurahDetailSection: SectionModelType {
    case cardPlaceholder(item: DetailCardPlaceholderTableViewCellViewModel?)
    case ayahPlaceholder(item: [ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]?)
    case card(item: DetailCardTableViewCellViewModel?)
    case ayah(item: [ButtonHeaderTitleWithSubtitleTableViewCellViewModel]?)

    var items: [AnyObject] {
        switch self {
        case .cardPlaceholder(let item):
            return item != nil ? [item!] : []
        case .ayahPlaceholder(let item):
            return item != nil ? item! : []
        case .card(let item):
            return item != nil ? [item!] : []
        case .ayah(let item):
            return item != nil ? item! : []
        }
    }
    
    init(original: SurahDetailSection, items: [AnyObject]) {
        switch original {
        case .cardPlaceholder:
            self = .cardPlaceholder(item: items.first as? DetailCardPlaceholderTableViewCellViewModel)
        case .ayahPlaceholder:
            self = .ayahPlaceholder(item: items as? [ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel])
        case .card:
            self = .card(item: items.first as? DetailCardTableViewCellViewModel)
        case .ayah:
            self = .ayah(item: items as? [ButtonHeaderTitleWithSubtitleTableViewCellViewModel])
        }
    }
}

extension SurahDetailSection: TableViewDataSource {
    typealias Section = SurahDetailSection
    
    static var allCases: [SurahDetailSection] {
        return [
            .cardPlaceholder(item: DetailCardPlaceholderTableViewCellViewModel()),
            .ayahPlaceholder(item: nil),
            .card(item: DetailCardTableViewCellViewModel()),
            .ayah(item: nil),
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<SurahDetailSection> {
        return RxTableViewSectionedReloadDataSource<SurahDetailSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? DetailCardPlaceholderTableViewCellViewModel {
                let newCell = tableView.dequeueCell(DetailCardPlaceholderTableViewCell<DetailCardPlaceholderTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel {
                let newCell = tableView.dequeueCell(ButtonHeaderTitleWithSubtitlePlaceholderTableViewCell<ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? DetailCardTableViewCellViewModel {
                let newCell = tableView.dequeueCell(DetailCardTableViewCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? ButtonHeaderTitleWithSubtitleTableViewCellViewModel {
                let newCell = tableView.dequeueCell(ButtonHeaderTitleWithSubtitleTableViewCell.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            }
            
            return cell
        })
    }
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .cardPlaceholder:
            return DetailCardPlaceholderTableViewCell<DetailCardPlaceholderTableViewCellViewModel>.self
        case .ayahPlaceholder:
            return ButtonHeaderTitleWithSubtitlePlaceholderTableViewCell<ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel>.self
        case .card:
            return DetailCardTableViewCell.self
        case .ayah:
            return ButtonHeaderTitleWithSubtitleTableViewCell.self
        }
    }
}

extension SurahDetailSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .cardPlaceholder:
            return 0
        case .ayahPlaceholder:
            return 1
        case .card:
            return 2
        case .ayah:
            return 3
        }
    }
}
