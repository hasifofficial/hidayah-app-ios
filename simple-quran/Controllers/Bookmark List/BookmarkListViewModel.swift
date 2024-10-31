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
    var surahList: CurrentValueSubject<[SurahListResponse]?, Never> { get }
    var filteredSurahList: CurrentValueSubject<[SurahBookmark]?, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }
    
    func handleSuccess(value: SurahList)
    
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
    var surahEmptyCell: CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("bookmark_list_empty_list_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]
        )
        attributedText.append(NSAttributedString(
            string: NSLocalizedString("bookmark_list_empty_list_subtitle", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        ))
        
        let vm = SectionTitleTableViewCellViewModel()
        vm.titleLabelAttributedText.send(attributedText)
        vm.titleLabelTextAlignment.send(.center)
        vm.containerTopSpacing.send(100)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel?, Never>(vm)
    }()
    let surahList = CurrentValueSubject<[SurahListResponse]?, Never>(nil)
    let filteredSurahList = CurrentValueSubject<[SurahBookmark]?, Never>(nil)
    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<BookmarkListSection> = Section.generateDataSource()
    var sectionCache = [Int : BookmarkListSection]()
    private(set) var sectionedItems = BehaviorRelay<[BookmarkListSection]>(value: [])
    
    func handleSuccess(value: SurahList) {
        guard let surahs = value.data else { return }
        
        surahList.send(surahs)
        
        if let recentBookmarks: [SurahBookmark] = Storage.loadObject(key: .bookmarkRecitations) {
            let sortedRecentBookmarks = recentBookmarks.sorted {
                if $0.surahNumber == $1.surahNumber {
                    return $0.numberInSurah < $1.numberInSurah
                }
                return $0.surahNumber < $1.surahNumber
            }
            
            var tempSurahCells = [DetailTitleTableViewCellViewModel]()
            for filteredSurah in sortedRecentBookmarks {
                guard let surah = surahList.value?.first(where: { $0.number == filteredSurah.surahNumber }) else { return }
                
                let tempSurahCell = DetailTitleTableViewCellViewModel()
                tempSurahCell.rightTitleLabelText.send(surah.name)
                tempSurahCell.leftTitleLabelText.send(surah.englishName)
                tempSurahCell.leftSubtitleLabelText.send(
                    String(
                        format: NSLocalizedString(
                            "bookmark_list_subtitle",
                            comment: ""
                        ),
                        String(filteredSurah.numberInSurah)
                    )
                )
                tempSurahCells.append(tempSurahCell)
            }
            
            filteredSurahList.send(sortedRecentBookmarks)
            surahCell.send(tempSurahCells)
            surahEmptyCell.send(nil)
        } else {
            let attributedText = NSMutableAttributedString(
                string: NSLocalizedString("bookmark_list_empty_list_title", comment: ""),
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]
            )
            attributedText.append(NSAttributedString(
                string: NSLocalizedString("bookmark_list_empty_list_subtitle", comment: ""),
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
