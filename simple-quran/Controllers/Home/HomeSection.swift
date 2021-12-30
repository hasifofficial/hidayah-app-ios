//
//  HomeSection.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import RxDataSources

enum HomeSection: SectionModelType {
    case prayerTime(item: LabelsWithRightIconHeaderTableViewCellViewModel?)
    case date(item: LabelWithLeftIconTableViewCellViewModel?)
    case location(item: LabelWithLeftIconTableViewCellViewModel?)

    var items: [AnyObject] {
        switch self {
        case .prayerTime(let item):
            return item != nil ? [item!] : []
        case .date(let item):
            return item != nil ? [item!] : []
        case .location(let item):
            return item != nil ? [item!] : []
        }
    }
    
    init(original: HomeSection, items: [AnyObject]) {
        switch original {
        case .prayerTime:
            self = .prayerTime(item: items.first as? LabelsWithRightIconHeaderTableViewCellViewModel)
        case .date:
            self = .date(item: items.first as? LabelWithLeftIconTableViewCellViewModel)
        case .location:
            self = .location(item: items.first as? LabelWithLeftIconTableViewCellViewModel)
        }
    }
}

extension HomeSection: TableViewDataSource {
    typealias Section = HomeSection
    
    static var allCases: [HomeSection] {
        return [
            .prayerTime(item: nil),
            .date(item: nil),
            .location(item: nil),
        ]
    }
    
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<HomeSection> {
        return RxTableViewSectionedReloadDataSource<HomeSection>(configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
            var cell: UITableViewCell!
            
            if let viewModel = viewModel as? LabelsWithRightIconHeaderTableViewCellViewModel {
                let newCell = tableView.dequeueCell(LabelsWithRightIconHeaderTableViewCell<LabelsWithRightIconHeaderTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            } else if let viewModel = viewModel as? LabelWithLeftIconTableViewCellViewModel {
                let newCell = tableView.dequeueCell(LabelWithLeftIconTableViewCell<LabelWithLeftIconTableViewCellViewModel>.self, at: indexPath)
                newCell.configureWith(value: viewModel)
                cell = newCell
            }
            
            return cell
        })
    }
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .prayerTime:
            return LabelsWithRightIconHeaderTableViewCell<LabelsWithRightIconHeaderTableViewCellViewModel>.self
        case .date, .location:
            return LabelWithLeftIconTableViewCell<LabelWithLeftIconTableViewCellViewModel>.self
        }
    }
}

extension HomeSection: RelativeOrder {
    var sectionOrder: Int {
        switch self {
        case .prayerTime:
            return 0
        case .date:
            return 1
        case .location:
            return 2
        }
    }
}
