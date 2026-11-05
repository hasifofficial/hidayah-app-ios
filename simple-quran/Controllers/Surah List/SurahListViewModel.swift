//
//  SurahListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SurahListViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SurahListSection {
    var title: CurrentValueSubject<String, Never> { get }
    var surahPlaceholderCell: CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never> { get }
    var surahCell: CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never> { get }
    var surahEmptyCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> { get }
    var surahList: CurrentValueSubject<[SurahListResponse]?, Never> { get }
    var filteredSurahList: CurrentValueSubject<[SurahListResponse]?, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }
    
    func handleSuccess(value: SurahList)
    func filterSurah(keyword: String?)
    
    init()
}

class SurahListViewModel: SurahListViewModelTypes {
    let surahPlaceholderCell: CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never> = {
        var vm = [DetailTitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<10 {
            vm.append(DetailTitlePlaceholderTableViewCellViewModel())
        }
        
        return CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never>(vm)
    }()

    let title = CurrentValueSubject<String, Never>(NSLocalizedString(
        "surah_list_header_title",
        comment: ""
    ))
    let surahCell = CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never>(nil)
    let surahEmptyCell = CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(nil)
    let surahList = CurrentValueSubject<[SurahListResponse]?, Never>(nil)
    let filteredSurahList = CurrentValueSubject<[SurahListResponse]?, Never>(nil)
    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<SurahListSection> = Section.generateDataSource()
    var sectionCache = [Int : SurahListSection]()
    private(set) var sectionedItems = BehaviorRelay<[SurahListSection]>(value: [])
    
    func handleSuccess(value: SurahList) {
        guard let surahs = value.data else { return }
        
        surahList.send(surahs)
        
        filterSurah(keyword: nil)
    }
    
    func filterSurah(keyword: String?) {
        guard let surahList = surahList.value else { return }
        
        if let keyword = keyword?.lowercased(), !keyword.isEmpty {
            filteredSurahList.send(surahList.filter { $0.englishName?.lowercased().contains(keyword) ?? false })
        } else {
            filteredSurahList.send(surahList)
        }
        
        guard let filteredSurahs = filteredSurahList.value else { return }
        
        var tempSurahCells = [DetailTitleTableViewCellViewModel]()
        
        if filteredSurahs.count > 0 {
            for surah in filteredSurahs {
                guard let name = surah.name,
                      let englishName = surah.englishName,
                      let origin = surah.revelationType,
                      let noOfAyahs = surah.numberOfAyahs else { return }
                
                let tempSurahCell = DetailTitleTableViewCellViewModel()
                tempSurahCell.rightTitleLabelText.send(name)
                tempSurahCell.leftTitleLabelText.send(englishName)
                tempSurahCell.leftSubtitleLabelText.send(
                    String(
                        format: NSLocalizedString(
                            "surah_list_subtitle",
                            comment: ""
                        ),
                        origin.lowercased() == "meccan" ? "Makiyyah" : "Madaniyah",
                        String(noOfAyahs)
                    )
                )

                tempSurahCells.append(tempSurahCell)
            }
            
            surahEmptyCell.send(nil)
            surahCell.send(tempSurahCells)
        } else {
            let attributedText = NSMutableAttributedString(
                string: NSLocalizedString(
                    "surah_list_search_empty_title",
                    comment: ""
                ),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold)
                ]
            )
            attributedText.append(NSAttributedString(
                string: NSLocalizedString(
                    "surah_list_search_empty_subtitle",
                    comment: ""
                ),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.textGray
                ]
            ))
            
            let tempEmptyStateCells = SectionTitleTableViewCellViewModel()
            tempEmptyStateCells.titleLabelAttributedText.send(attributedText)
            tempEmptyStateCells.titleLabelTextAlignment.send(.center)
            tempEmptyStateCells.containerTopSpacing.send(100)
            
            surahEmptyCell.send(tempEmptyStateCells)
            surahCell.send(nil)
        }
        
        surahPlaceholderCell.send(nil)
    }
        
    required init() {
        
    }
}
