//
//  BookmarkListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/31/24.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol BookmarkListViewModelTypes: SectionSetter, TableViewSectionSetter where Section == BookmarkListSection {
    var title: CurrentValueSubject<String, Never> { get }
    var surahPlaceholderCell: CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never> { get }
    var surahCell: CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never> { get }
    var surahEmptyCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> { get }
    var bookmarkedSurahList: CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never> { get }
    var filteredSurahList: CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }
    
    func handleSuccess(value: SurahList)
    func filterSurah(keyword: String?)
    
    init()
}

class BookmarkListViewModel: BookmarkListViewModelTypes {
    let surahPlaceholderCell: CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never> = {
        var vm = [DetailTitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<10 {
            vm.append(DetailTitlePlaceholderTableViewCellViewModel())
        }
        
        return CurrentValueSubject<[DetailTitlePlaceholderTableViewCellViewModel]?, Never>(vm)
    }()

    let title = CurrentValueSubject<String, Never>(NSLocalizedString("bookmark_list_header_title", comment: ""))
    let surahCell = CurrentValueSubject<[DetailTitleTableViewCellViewModel]?, Never>(nil)
    var surahEmptyCell = CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(nil)
    let bookmarkedSurahList = CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never>(nil)
    let filteredSurahList = CurrentValueSubject<[(surahDetail: SurahListResponse?, bookmarkDetail: SurahBookmark?)]?, Never>(nil)
    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<BookmarkListSection> = Section.generateDataSource()
    var sectionCache = [Int : BookmarkListSection]()
    private(set) var sectionedItems = BehaviorRelay<[BookmarkListSection]>(value: [])
    
    func handleSuccess(value: SurahList) {
        guard let surahs = value.data else { return }

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

        filterSurah(keyword: nil)
    }
    
    func filterSurah(keyword: String?) {
        guard let bookmarkedSurahList = bookmarkedSurahList.value else { return }

        if let keyword = keyword?.lowercased(), !keyword.isEmpty {
            filteredSurahList.send(bookmarkedSurahList.filter { $0.surahDetail?.englishName?.lowercased().contains(keyword) ?? false })
        } else {
            filteredSurahList.send(bookmarkedSurahList)
        }
        
        guard let filteredSurahs = filteredSurahList.value else { return }
        
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
            surahCell.send(tempSurahCells)
        } else {
            let attributedText = NSMutableAttributedString(
                string: NSLocalizedString("bookmark_list_search_empty_title", comment: ""),
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]
            )
            attributedText.append(NSAttributedString(
                string: NSLocalizedString("bookmark_list_search_empty_subtitle", comment: ""),
                attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
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
