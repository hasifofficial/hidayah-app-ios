//
//  TableViewDataSource.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import RxDataSources

protocol TableViewDataSource: CaseIterable {
    associatedtype Section where Section: SectionModelType, Section == Self
    var cellType: UITableViewCell.Type { get }
    static func generateDataSource() -> RxTableViewSectionedReloadDataSource<Section>
}
