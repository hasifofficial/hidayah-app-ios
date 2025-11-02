//
//  SearchSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/1/25.
//

import RxDataSources

enum SearchSection: SectionModelType {
    case surahPlaceholder(item: [DetailTitlePlaceholderTableViewCellViewModel]?)
    case bookmarkedSurahTitle(item: SectionTitleTableViewCellViewModel?)
    case bookmarkedSurah(item: [DetailTitleTableViewCellViewModel]?)
    case surahTitle(item: SectionTitleTableViewCellViewModel?)
    case surah(item: [DetailTitleTableViewCellViewModel]?)
    case surahEmpty(item: SectionTitleTableViewCellViewModel?)

    var items: [AnyObject] {
        switch self {
        case .surahPlaceholder(let item):
            return item != nil ? item! : []
        case .bookmarkedSurahTitle(let item):
            return item != nil ? [item!] : []
        case .bookmarkedSurah(let item):
            return item != nil ? item! : []
        case .surahTitle(let item):
            return item != nil ? [item!] : []
        case .surah(let item):
            return item != nil ? item! : []
        case .surahEmpty(let item):
            return item != nil ? [item!] : []
        }
    }
    
    init(original: SearchSection, items: [AnyObject]) {
        switch original {
        case .surahPlaceholder:
            self = .surahPlaceholder(item: items as? [DetailTitlePlaceholderTableViewCellViewModel])
        case .bookmarkedSurahTitle, .surahTitle, .surahEmpty:
            self = .bookmarkedSurahTitle(item: items.first as? SectionTitleTableViewCellViewModel)
        case .bookmarkedSurah, .surah:
            self = .bookmarkedSurah(item: items as? [DetailTitleTableViewCellViewModel])
        }
    }
}

extension SearchSection: TableViewDataSource {
    typealias Section = SearchSection
    
    static var allCases: [SearchSection] {
        return [
            .surahPlaceholder(item: nil),
            .bookmarkedSurahTitle(item: nil),
            .bookmarkedSurah(item: nil),
            .surahTitle(item: nil),
            .surah(item: nil),
            .surahEmpty(item: nil)
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<SearchSection> {
        return RxTableViewSectionedReloadDataSource<SearchSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
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
        case .bookmarkedSurahTitle, .surahTitle, .surahEmpty:
            return SectionTitleTableViewCell<SectionTitleTableViewCellViewModel>.self
        case .bookmarkedSurah, .surah:
            return DetailTitleTableViewCell<DetailTitleTableViewCellViewModel>.self
        }
    }
}

extension SearchSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .surahPlaceholder:
            return 0
        case .bookmarkedSurahTitle:
            return 1
        case .bookmarkedSurah:
            return 2
        case .surahTitle:
            return 3
        case .surah:
            return 4
        case .surahEmpty:
            return 5
        }
    }
}
