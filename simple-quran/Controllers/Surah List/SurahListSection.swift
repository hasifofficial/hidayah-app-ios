//
//  SurahListSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import RxDataSources

enum SurahListSection: SectionModelType {
    case surahPlaceholder(item: [DetailTitlePlaceholderTableViewCellViewModel]?)
    case surah(item: [DetailTitleTableViewCellViewModel]?)
    case surahEmpty(item: SectionTitleTableViewCellViewModel?)

    var items: [AnyObject] {
        switch self {
        case .surahPlaceholder(let item):
            return item != nil ? item! : []
        case .surah(let item):
            return item != nil ? item! : []
        case .surahEmpty(let item):
            return item != nil ? [item!] : []
        }
    }
    
    init(original: SurahListSection, items: [AnyObject]) {
        switch original {
        case .surahPlaceholder:
            self = .surahPlaceholder(item: items as? [DetailTitlePlaceholderTableViewCellViewModel])
        case .surah:
            self = .surah(item: items as? [DetailTitleTableViewCellViewModel])
        case .surahEmpty:
            self = .surahEmpty(item: items.first as? SectionTitleTableViewCellViewModel)
        }
    }
}

extension SurahListSection: TableViewDataSource {
    typealias Section = SurahListSection
    
    static var allCases: [SurahListSection] {
        return [
            .surahPlaceholder(item: nil),
            .surah(item: nil),
            .surahEmpty(item: nil)
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<SurahListSection> {
        return RxTableViewSectionedReloadDataSource<SurahListSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? DetailTitlePlaceholderTableViewCellViewModel {
                let newCell = tableView.dequeueCell(DetailTitlePlaceholderTableViewCell<DetailTitlePlaceholderTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? DetailTitleTableViewCellViewModel {
                let newCell = tableView.dequeueCell(DetailTitleTableViewCell<DetailTitleTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? SectionTitleTableViewCellViewModel {
                let newCell = tableView.dequeueCell(SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            }
            
            return cell
        })
    }
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .surahPlaceholder:
            return DetailTitlePlaceholderTableViewCell<DetailTitlePlaceholderTableViewCellViewModel>.self
        case .surah:
            return DetailTitleTableViewCell<DetailTitleTableViewCellViewModel>.self
        case .surahEmpty:
            return SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self
        }
    }
}

extension SurahListSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .surahPlaceholder:
            return 0
        case .surah:
            return 1
        case .surahEmpty:
            return 2
        }
    }
}
