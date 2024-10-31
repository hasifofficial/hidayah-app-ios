//
//  SurahDetailViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SurahDetailViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SurahDetailSection {
    var title: CurrentValueSubject<String?, Never> { get }
    var cardPlaceholderCell: CurrentValueSubject<DetailCardPlaceholderTableViewCellViewModel?, Never> { get }
    var ayahPlaceholderCell: CurrentValueSubject<[ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]?, Never> { get }
    var cardCell: CurrentValueSubject<DetailCardTableViewCellViewModel?, Never> { get }
    var ayahCell: CurrentValueSubject<[ButtonHeaderTitleWithSubtitleTableViewCellViewModel]?, Never> { get }
    var selectedSurahNo: CurrentValueSubject<Int?, Never> { get }
    var ayahList: CurrentValueSubject<[Ayah]?, Never> { get }
    var recitationList: CurrentValueSubject<[EditionResponse]?, Never> { get }
    var newRecitationListItem: CurrentValueSubject<[ItemSelector]?, Never> { get }
    var selectedRecitationItem: CurrentValueSubject<ItemSelector?, Never> { get }
    var translationList: CurrentValueSubject<[EditionResponse]?, Never> { get }
    var newTranslationListItem: CurrentValueSubject<[ItemSelector]?, Never> { get }
    var selectedTranslationListItem: CurrentValueSubject<ItemSelector?, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }
    
    func handleSurahDetailSuccess(value: Surah)
    func handleEditionSuccess(value: Edition)

    init()
}

class SurahDetailViewModel: SurahDetailViewModelTypes {
    let cardPlaceholderCell: CurrentValueSubject<DetailCardPlaceholderTableViewCellViewModel?, Never> = {
        let vm = DetailCardPlaceholderTableViewCellViewModel()
        return CurrentValueSubject<DetailCardPlaceholderTableViewCellViewModel?, Never>(vm)
    }()
    
    let ayahPlaceholderCell: CurrentValueSubject<[ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]?, Never> = {
        var vm = [ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<3 {
            vm.append(ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel())
        }
        
        return CurrentValueSubject<[ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]?, Never>(vm)
    }()

    let title = CurrentValueSubject<String?, Never>(nil)
    let cardCell = CurrentValueSubject<DetailCardTableViewCellViewModel?, Never>(nil)
    let ayahCell = CurrentValueSubject<[ButtonHeaderTitleWithSubtitleTableViewCellViewModel]?, Never>(nil)
    let selectedSurahNo = CurrentValueSubject<Int?, Never>(nil)
    let ayahList = CurrentValueSubject<[Ayah]?, Never>(nil)
    let recitationList = CurrentValueSubject<[EditionResponse]?, Never>(nil)
    let newRecitationListItem = CurrentValueSubject<[ItemSelector]?, Never>(nil)
    let selectedRecitationItem = CurrentValueSubject<ItemSelector?, Never>(nil)
    let translationList = CurrentValueSubject<[EditionResponse]?, Never>(nil)
    let newTranslationListItem = CurrentValueSubject<[ItemSelector]?, Never>(nil)
    let selectedTranslationListItem = CurrentValueSubject<ItemSelector?, Never>(nil)
    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<SurahDetailSection> = Section.generateDataSource()
    var sectionCache = [Int : SurahDetailSection]()
    private(set) var sectionedItems = BehaviorRelay<[SurahDetailSection]>(value: [])
    
    func handleSurahDetailSuccess(value: Surah) {
        guard let surahEditions = value.data,
              let surahName = surahEditions.first?.englishName,
              let origin = surahEditions.first?.revelationType,
              let surahNo = surahEditions.first?.number,
              let noOfAyahs = surahEditions.first?.numberOfAyahs,
              let translationSurahName = surahEditions.first?.englishNameTranslation,
              let ayahs = surahEditions.first?.ayahs,
              let translationAyahs = surahEditions.last?.ayahs,
              let translationAyahsEdition = surahEditions.last?.edition,
              let textDirection = translationAyahsEdition.direction else { return }
        
        let tempCardCell = DetailCardTableViewCellViewModel()
        tempCardCell.titleLabelText.accept(surahName)
        tempCardCell.detailLabelText.accept(
            String(format: NSLocalizedString("surah_description", comment: ""), surahName, translationSurahName, String(noOfAyahs), String(surahNo), origin.lowercased() == "meccan" ? "Makkah" : "Madinah")
        )
        
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let reciterName = selectedRecitationData?.englishName ?? "Alafasy"

        tempCardCell.leftButtonText.accept(reciterName)
        
        var language = "English"
        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        if let translatedLanguage = selectedTranslationData?.language {
            language = Constants.getLanguageFromCode(code: translatedLanguage)
        }
        
        tempCardCell.rightButtonText.accept(language)

        var tempAyahCells = [ButtonHeaderTitleWithSubtitleTableViewCellViewModel]()

        for (index, ayah) in ayahs.enumerated() {
            guard let arabicVerse = ayah.text,
                  let arabicVerseNo = ayah.numberInSurah,
                  let translationVerse = translationAyahs[index].text else { return }
            
            let tempAyahCell = ButtonHeaderTitleWithSubtitleTableViewCellViewModel()
            
            if surahEditions.first?.number != 1 && ayah.numberInSurah == 1 {
                let tempArabicVerse = (arabicVerse as NSString).replacingOccurrences(of: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ", with: "")
                tempAyahCell.titleLabelText.accept(tempArabicVerse)
            } else {
                tempAyahCell.titleLabelText.accept(arabicVerse)
            }

            if let recentBookmarks: [SurahBookmark] = Storage.loadObject(key: .bookmarkRecitations),
               recentBookmarks.contains(where: { $0.surahNumber == selectedSurahNo.value && $0.numberInSurah == index + 1 }) {
                tempAyahCell.rightHeaderButtonImage.accept(
                    UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysTemplate)
                )
            } else {
                tempAyahCell.rightHeaderButtonImage.accept(
                    UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate)
                )
            }

            tempAyahCell.circleNumberText.accept("\(arabicVerseNo)")
            tempAyahCell.titleLabelTextFont.accept(.kitabRegular(size: 22))
            tempAyahCell.titleLabelTextAlignment.accept(.right)
            tempAyahCell.subtitleLabelText.accept(translationVerse)
            tempAyahCell.subtitleLabelTextAlignment.accept(textDirection == .leftToRight ? .left : .right)
            tempAyahCell.data.accept(ayah)
            
            tempAyahCells.append(tempAyahCell)
        }
        
        cardPlaceholderCell.send(nil)
        ayahPlaceholderCell.send(nil)
        cardCell.send(tempCardCell)
        ayahCell.send(tempAyahCells)
        ayahList.send(ayahs)
    }
    
    func handleEditionSuccess(value: Edition) {
        guard let editions = value.data else { return }
        
        let recitationEditions = editions.filter({ $0.format == .audio && $0.language == "ar" && $0.type == "versebyverse" })
        let translationEditions = editions.filter({ $0.format == .text && $0.type == "translation" })
        
        var newRecitationItems = [ItemSelector]()
        var newTranslationItems = [ItemSelector]()

        for recitationEdition in recitationEditions {
            let qariName = recitationEdition.englishName ?? ""

            newRecitationItems.append(
                ItemSelector(
                    title: qariName,
                    value: "",
                    item: recitationEdition
                )
            )
        }

        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        if let selectedRecitationData {
            let qariName = selectedRecitationData.englishName ?? ""

            selectedRecitationItem.send(
                ItemSelector(
                    title: qariName,
                    value: "",
                    item: selectedRecitationData
                )
            )
        }

        for translationEdition in translationEditions {
            let translationLanguage = translationEdition.language ?? ""
            let translationName = translationEdition.name ?? ""

            let language = Constants.getLanguageFromCode(code: translationLanguage)
            
            newTranslationItems.append(
                ItemSelector(
                    title: "\(language) - \(translationName)",
                    value: "",
                    item: translationEdition
                )
            )
        }

        recitationList.send(recitationEditions)
        newRecitationListItem.send(newRecitationItems)
        translationList.send(translationEditions)
        newTranslationListItem.send(newTranslationItems)
    }
        
    required init() {
        
    }
}
