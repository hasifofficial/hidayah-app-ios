//
//  SearchViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/1/25.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SearchViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SearchSection {
    var title: CurrentValueSubject<String, Never> { get }
    var surahPlaceholderCell: CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never> { get }
    var bookmarkedSurahTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> { get }
    var bookmarkedSurahCell: CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never> { get }
    var surahTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> { get }
    var surahCell: CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never> { get }
    var surahEmptyCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> { get }
    var surahList: CurrentValueSubject<[SurahListResponse]?, Never> { get }
    var bookmarkedSurahList: CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never> { get }
    var filteredSurahList: CurrentValueSubject<[SurahListResponse]?, Never> { get }
    var filteredBookmarkedSurahList: CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }
    
    func handleSuccess(value: SurahList)
    func filterSurah(keyword: String?)
    
    init()
}

class SearchViewModel: SearchViewModelTypes {
    let surahPlaceholderCell: CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never> = {
        var vm = [DetailTitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<10 {
            vm.append(DetailTitlePlaceholderTableViewCellViewModel())
        }
        
        return CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never>(vm)
    }()

    let title = CurrentValueSubject<String, Never>(NSLocalizedString(
        "search_header_title",
        comment: ""
    ))
    let bookmarkedSurahTitleCell = CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(nil)
    let bookmarkedSurahCell = CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never>(nil)
    let surahTitleCell = CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(nil)
    let surahCell = CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never>(nil)
    let surahEmptyCell = CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(nil)
    let surahList = CurrentValueSubject<[SurahListResponse]?, Never>(nil)
    let bookmarkedSurahList = CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never>(nil)
    let filteredSurahList = CurrentValueSubject<[SurahListResponse]?, Never>(nil)
    let filteredBookmarkedSurahList = CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never>(nil)
    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<SearchSection> = Section.generateDataSource()
    var sectionCache = [Int : SearchSection]()
    private(set) var sectionedItems = BehaviorRelay<[SearchSection]>(value: [])
    
    func handleSuccess(value: SurahList) {
        guard let surahs = value.data else { return }
        
        surahList.send(surahs)
        filterBookmarkedSurahs(from: surahs)
        
        filterSurah(keyword: nil)
    }
        
    func filterSurah(keyword: String?) {
        guard let surahList = surahList.value,
              let bookmarkedSurahList = bookmarkedSurahList.value else { return }
        
        if let keyword = keyword?.lowercased(), !keyword.isEmpty {
            filteredSurahList.send(surahList.filter { $0.englishName?.lowercased().contains(keyword) ?? false })
            filteredBookmarkedSurahList.send(bookmarkedSurahList.filter { $0.surahDetail?.englishName?.lowercased().contains(keyword) ?? false })
        } else {
            filteredSurahList.send(surahList)
            filteredBookmarkedSurahList.send(bookmarkedSurahList)
        }
        
        if let keyword, !keyword.isEmpty {
            handleBookmarkedSurahListUpdate(keyword: keyword)
            handleSearchSurahListUpdate(keyword: keyword)
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
            bookmarkedSurahTitleCell.send(nil)
            bookmarkedSurahCell.send(nil)
            surahTitleCell.send(nil)
            surahCell.send(nil)
        }
        
        surahPlaceholderCell.send(nil)
    }
        
    required init() {
        
    }
}

extension SearchViewModel {
    private func filterBookmarkedSurahs(from surahs: [SurahListResponse]) {
        var tempBookmarkedSurahList = [(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]()
        if let recentBookmarks: [SurahBookmark] = Storage.loadObject(key: .bookmarkRecitations) {
            let sortedRecentBookmarks = recentBookmarks.sorted {
                if $0.surahNumber == $1.surahNumber {
                    return $0.numberInSurah < $1.numberInSurah
                }
                return $0.surahNumber < $1.surahNumber
            }

            for filteredSurah in sortedRecentBookmarks {
                guard let surah = surahs.first(where: { $0.number == filteredSurah.surahNumber }) else { return }
                
                tempBookmarkedSurahList.append(
                    (
                        surahDetail: surah,
                        bookmarkDetail: filteredSurah
                    )
                )
            }
        }
        bookmarkedSurahList.send(tempBookmarkedSurahList)
    }
    
    private func handleBookmarkedSurahListUpdate(keyword: String) {
        guard let filteredSurahs = filteredBookmarkedSurahList.value else { return }
        
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString(
                "search_bookmarked_surah_section_title",
                comment: ""
            ),
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.title
            ]
        )
        
        let tempBookmarkedSurahTitleCell = SectionTitleTableViewCellViewModel()
        
        tempBookmarkedSurahTitleCell.titleLabelAttributedText.send(attributedText)
        tempBookmarkedSurahTitleCell.containerBottomSpacing.send(0)

        var tempSurahCells = [DetailTitleTableViewCellViewModel]()
        if filteredSurahs.count > 0 {
            for surah in filteredSurahs {
                guard let bookmarkDetail = surah.bookmarkDetail,
                      let surahDetail = surah.surahDetail,
                      let name = surahDetail.name,
                      let englishName = surahDetail.englishName else { return }
                
                let tempSurahCell = DetailTitleTableViewCellViewModel()
                tempSurahCell.rightTitleLabelText.send(name)
                tempSurahCell.leftTitleLabelText.send(englishName)
                tempSurahCell.leftSubtitleLabelText.send(
                    String(
                        format: NSLocalizedString(
                            "bookmark_list_subtitle",
                            comment: ""
                        ),
                        String(bookmarkDetail.numberInSurah)
                    )
                )
                tempSurahCells.append(tempSurahCell)
            }
            
            surahEmptyCell.send(nil)
            bookmarkedSurahTitleCell.send(tempBookmarkedSurahTitleCell)
            bookmarkedSurahCell.send(tempSurahCells)
//        } else {
//            let attributedText = NSMutableAttributedString(
//                string: NSLocalizedString(
//                    "bookmark_list_search_empty_title",
//                    comment: ""
//                ),
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 14, weight: .bold)
//                ]
//            )
//            attributedText.append(NSAttributedString(
//                string: NSLocalizedString(
//                    "bookmark_list_search_empty_subtitle",
//                    comment: ""
//                ),
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 14),
//                    .foregroundColor: UIColor.textGray
//                ]
//            ))
//            
//            let tempEmptyStateCells = SectionTitleTableViewCellViewModel()
//            tempEmptyStateCells.titleLabelAttributedText.send(attributedText)
//            tempEmptyStateCells.titleLabelTextAlignment.send(.center)
//            tempEmptyStateCells.containerTopSpacing.send(100)
//            
//            surahEmptyCell.send(tempEmptyStateCells)
//            surahCell.send(nil)
        }
    }
    
    private func handleSearchSurahListUpdate(keyword: String) {
        guard let filteredSurahs = filteredSurahList.value else { return }
        
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString(
                "search_surah_section_title",
                comment: ""
            ),
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.title
            ]
        )
        
        let tempSurahTitleCell = SectionTitleTableViewCellViewModel()
        
        tempSurahTitleCell.titleLabelAttributedText.send(attributedText)
        tempSurahTitleCell.containerBottomSpacing.send(0)

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
            surahTitleCell.send(tempSurahTitleCell)
            surahCell.send(tempSurahCells)
//        } else {
//            let attributedText = NSMutableAttributedString(
//                string: NSLocalizedString(
//                    "surah_list_search_empty_title",
//                    comment: ""
//                ),
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 14, weight: .bold)
//                ]
//            )
//            attributedText.append(NSAttributedString(
//                string: NSLocalizedString(
//                    "surah_list_search_empty_subtitle",
//                    comment: ""
//                ),
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 14),
//                    .foregroundColor: UIColor.textGray
//                ]
//            ))
//            
//            let tempEmptyStateCells = SectionTitleTableViewCellViewModel()
//            tempEmptyStateCells.titleLabelAttributedText.send(attributedText)
//            tempEmptyStateCells.titleLabelTextAlignment.send(.center)
//            tempEmptyStateCells.containerTopSpacing.send(100)
//            
//            surahEmptyCell.send(tempEmptyStateCells)
//            surahCell.send(nil)
        }
    }
}
