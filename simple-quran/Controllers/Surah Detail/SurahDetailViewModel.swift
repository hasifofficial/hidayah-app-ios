//
//  SurahDetailViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SurahDetailViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SurahDetailSection {
    var title: BehaviorRelay<String?> { get }
    var cardPlaceholderCell: BehaviorRelay<DetailCardPlaceholderTableViewCellViewModel?> { get }
    var ayahPlaceholderCell: BehaviorRelay<[ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]?> { get }
    var cardCell: BehaviorRelay<DetailCardTableViewCellViewModel?> { get }
    var ayahCell: BehaviorRelay<[ButtonHeaderTitleWithSubtitleTableViewCellViewModel]?> { get }
    var reciterDrawer: BehaviorRelay<PickerDrawerViewModel?> { get }
    var translateLanguageDrawer: BehaviorRelay<PickerDrawerViewModel?> { get }
    var selectedSurahNo: BehaviorRelay<Int?> { get }
    var ayahList: BehaviorRelay<[Ayah]?> { get }
    var recitationList: BehaviorRelay<[EditionResponse]?> { get }
    var translationList: BehaviorRelay<[EditionResponse]?> { get }
    var tapAction: BehaviorRelay<Action<Section.Item, Never>> { get }
    
    func handleSurahDetailSuccess(value: Surah)
    func handleEditionSuccess(value: Edition)

    init()
}

class SurahDetailViewModel: SurahDetailViewModelTypes {
    let cardPlaceholderCell: BehaviorRelay<DetailCardPlaceholderTableViewCellViewModel?> = {
        let vm = DetailCardPlaceholderTableViewCellViewModel()
        return BehaviorRelay(value: vm)
    }()
    
    let ayahPlaceholderCell: BehaviorRelay<[ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]?> = {
        var vm = [ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<3 {
            vm.append(ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel())
        }
        
        return BehaviorRelay(value: vm)
    }()

    let title = BehaviorRelay<String?>(value: nil)
    let cardCell = BehaviorRelay<DetailCardTableViewCellViewModel?>(value: nil)
    let ayahCell = BehaviorRelay<[ButtonHeaderTitleWithSubtitleTableViewCellViewModel]?>(value: nil)
    let reciterDrawer = BehaviorRelay<PickerDrawerViewModel?>(value: nil)
    let translateLanguageDrawer = BehaviorRelay<PickerDrawerViewModel?>(value: nil)
    let selectedSurahNo = BehaviorRelay<Int?>(value: nil)
    let ayahList = BehaviorRelay<[Ayah]?>(value: nil)
    let recitationList = BehaviorRelay<[EditionResponse]?>(value: nil)
    let translationList = BehaviorRelay<[EditionResponse]?>(value: nil)
    let tapAction = BehaviorRelay<Action<Section.Item, Swift.Never>>(value: Action { _ in
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
            
            tempAyahCell.circleNumberText.accept("\(arabicVerseNo)")
            tempAyahCell.titleLabelTextFont.accept(.kitabRegular(size: 22))
            tempAyahCell.titleLabelTextAlignment.accept(.right)
            tempAyahCell.subtitleLabelText.accept(translationVerse)
            tempAyahCell.subtitleLabelTextAlignment.accept(textDirection == .leftToRight ? .left : .right)
            tempAyahCell.data.accept(ayah)
            
            tempAyahCells.append(tempAyahCell)
        }
        
        cardPlaceholderCell.accept(nil)
        ayahPlaceholderCell.accept(nil)
        cardCell.accept(tempCardCell)
        ayahCell.accept(tempAyahCells)
        ayahList.accept(ayahs)
    }
    
    func handleEditionSuccess(value: Edition) {
        guard let editions = value.data else { return }
        
        let recitationEditions = editions.filter({ $0.format == .audio && $0.language == "ar" && $0.type == "versebyverse" })
        let translationEditions = editions.filter({ $0.format == .text && $0.type == "translation" })
        
        var recitationItems = [PickerItemSelectorObj]()
        var translationItems = [PickerItemSelectorObj]()
        
        for recitationEdition in recitationEditions {
            let qariName = recitationEdition.englishName ?? ""

            recitationItems.append(
                PickerItemSelectorObj(title: qariName,
                                      value: "",
                                      item: recitationEdition)
            )
        }
                
        for translationEdition in translationEditions {
            let translationLanguage = translationEdition.language ?? ""
            let translationName = translationEdition.name ?? ""

            let language = Constants.getLanguageFromCode(code: translationLanguage)
            
            translationItems.append(
                PickerItemSelectorObj(title: "\(language) - \(translationName)",
                                      value: "",
                                      item: translationEdition)
            )
        }
        
        let tempReciterDrawer = PickerDrawerViewModel(
            title: NSLocalizedString("surah_recitation_drawer_title", comment: ""),
            items: recitationItems
        )

        let tempTranslateLanguageDrawer = PickerDrawerViewModel(
            title: NSLocalizedString("surah_translation_drawer_title", comment: ""),
            items: translationItems
        )
        
        recitationList.accept(recitationEditions)
        translationList.accept(translationEditions)
        reciterDrawer.accept(tempReciterDrawer)
        translateLanguageDrawer.accept(tempTranslateLanguageDrawer)
    }
        
    required init() {
        
    }
}
