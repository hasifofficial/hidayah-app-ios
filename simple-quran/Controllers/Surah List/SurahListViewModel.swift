//
//  SurahListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SurahListViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SurahListSection {
    var title: BehaviorRelay<String> { get }
    var surahPlaceholderCell: BehaviorRelay<[DetailTitlePlaceholderTableViewCellViewModel]?> { get }
    var surahCell: BehaviorRelay<[DetailTitleTableViewCellViewModel]?> { get }
    var surahEmptyCell: BehaviorRelay<SectionTitleTableViewCellViewModel?> { get }
    var surahList: BehaviorRelay<[SurahListResponse]?> { get }
    var filteredSurahList: BehaviorRelay<[SurahListResponse]?> { get }
    var tapAction: BehaviorRelay<Action<Section.Item, Never>> { get }
    
    func handleSuccess(value: SurahList)
    func filterSurah(keyword: String?)
    
    init()
}

class SurahListViewModel: SurahListViewModelTypes {
    let surahPlaceholderCell: BehaviorRelay<[DetailTitlePlaceholderTableViewCellViewModel]?> = {
        var vm = [DetailTitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<10 {
            vm.append(DetailTitlePlaceholderTableViewCellViewModel())
        }
        
        return BehaviorRelay(value: vm)
    }()

    let title = BehaviorRelay<String>(value: NSLocalizedString("surah_list_header_title", comment: ""))
    let surahCell = BehaviorRelay<[DetailTitleTableViewCellViewModel]?>(value: nil)
    let surahEmptyCell = BehaviorRelay<SectionTitleTableViewCellViewModel?>(value: nil)
    let surahList = BehaviorRelay<[SurahListResponse]?>(value: nil)
    let filteredSurahList = BehaviorRelay<[SurahListResponse]?>(value: nil)
    let tapAction = BehaviorRelay<Action<Section.Item, Swift.Never>>(value: Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<SurahListSection> = Section.generateDataSource()
    var sectionCache = [Int : SurahListSection]()
    private(set) var sectionedItems = BehaviorRelay<[SurahListSection]>(value: [])
    
    func handleSuccess(value: SurahList) {
        guard let surahs = value.data else { return }
        
        surahList.accept(surahs)
        
        filterSurah(keyword: nil)
    }
    
    func filterSurah(keyword: String?) {
        guard let surahList = surahList.value else { return }
        
        if let keyword = keyword?.lowercased(), !keyword.isEmpty {
            filteredSurahList.accept(surahList.filter { $0.englishName?.lowercased().contains(keyword) ?? false })
        } else {
            filteredSurahList.accept(surahList)
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
                tempSurahCell.rightTitleLabelText.accept(name)
                tempSurahCell.leftTitleLabelText.accept(englishName)
                tempSurahCell.leftSubtitleLabelText.accept(
                    String(format: NSLocalizedString("surah_list_subtitle", comment: ""), origin.lowercased() == "meccan" ? "Makiyyah" : "Madaniyah", String(noOfAyahs))
                )

                tempSurahCells.append(tempSurahCell)
            }
            
            surahEmptyCell.accept(nil)
            surahCell.accept(tempSurahCells)
        } else {
            let attributedText = NSMutableAttributedString(
                string: NSLocalizedString("surah_list_search_empty_title", comment: ""),
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]
            )
            attributedText.append(NSAttributedString(
                string: NSLocalizedString("surah_list_search_empty_subtitle", comment: ""),
                attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
            ))
            
            let tempEmptyStateCells = SectionTitleTableViewCellViewModel()
            tempEmptyStateCells.titleLabelAttributedText.accept(attributedText)
            tempEmptyStateCells.titleLabelTextAlignment.accept(.center)
            tempEmptyStateCells.containerTopSpacing.accept(100)
            
            surahEmptyCell.accept(tempEmptyStateCells)
            surahCell.accept(nil)
        }
        
        surahPlaceholderCell.accept(nil)
    }
        
    required init() {
        
    }
}
