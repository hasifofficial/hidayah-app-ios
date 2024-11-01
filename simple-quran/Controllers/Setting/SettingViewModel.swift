//
//  SettingViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SettingViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SettingSection {
    var title: CurrentValueSubject<String, Never> { get }
    var quranSettingTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var recitationCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var translationLanguageCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var notificationSettingTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var kahfRemnderCell: CurrentValueSubject<SwitchTableViewCellViewModel, Never> { get }
    var aboutTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var aboutCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var privacyCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var termConditionCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var supportTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var feedbackCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var recitationList: CurrentValueSubject<[EditionResponse]?, Never> { get }
    var newRecitationList: CurrentValueSubject<[ItemSelector]?, Never> { get }
    var translationList: CurrentValueSubject<[EditionResponse]?, Never> { get }
    var newTranslationList: CurrentValueSubject<[ItemSelector]?, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }
    
    func handleEditionSuccess(value: Edition)
    
    init()
}

class SettingViewModel: SettingViewModelTypes {
    var quranSettingTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_quran_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor.title]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.send(attributedText)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var recitationCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let reciterName = selectedRecitationData?.englishName ?? "Alafasy"

        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_quran_recitation_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "speaker.wave.2.bubble")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.rightButtonText.send(reciterName)
        vm.rightButtonTextColor.send(.textGray)
        vm.shouldHideLeftButton.send(false)
        vm.shouldHideRightButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var translationLanguageCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        var language = "English"
        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        if let translatedLanguage = selectedTranslationData?.language {
            language = Constants.getLanguageFromCode(code: translatedLanguage)
        }
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_quran_translation_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "globe")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.rightButtonText.send(language)
        vm.rightButtonTextColor.send(.textGray)
        vm.shouldHideLeftButton.send(false)
        vm.shouldHideRightButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var notificationSettingTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_notification_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor.title]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.send(attributedText)
        vm.containerTopSpacing.send(24)
        vm.containerBottomSpacing.send(8)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()
    
    var kahfRemnderCell: CurrentValueSubject<SwitchTableViewCellViewModel, Never> = {
        let isSwitchOn = Storage.load(key: .allowKahfReminder) as? Bool ?? true
        let vm = SwitchTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_notification_alkahf_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "bell")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.isSwitchOn.send(isSwitchOn)
        
        return CurrentValueSubject<SwitchTableViewCellViewModel, Never>(vm)
    }()
    
    var aboutTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_about_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor.title]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.send(attributedText)
        vm.containerTopSpacing.send(24)
        vm.containerBottomSpacing.send(0)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()
    
    var aboutCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_about_us_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.shouldHideLeftButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var privacyCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_about_privacy_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "book.pages")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.shouldHideLeftButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()
    
    var termConditionCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_about_term_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "book.pages")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.shouldHideLeftButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject(vm)
    }()

    var supportTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_support_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor.title]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.send(attributedText)
        vm.containerTopSpacing.send(24)
        vm.containerBottomSpacing.send(0)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var feedbackCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString("setting_support_feedback_title", comment: ""))
        vm.leftButtonIcon.send(UIImage(systemName: "text.bubble")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.shouldHideLeftButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    let title = CurrentValueSubject<String, Never>(NSLocalizedString("setting_header_title", comment: ""))
    let recitationList = CurrentValueSubject<[EditionResponse]?, Never>(nil)
    let newRecitationList = CurrentValueSubject<[ItemSelector]?, Never>(nil)
    let translationList = CurrentValueSubject<[EditionResponse]?, Never>(nil)
    let newTranslationList = CurrentValueSubject<[ItemSelector]?, Never>(nil)
    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<SettingSection> = Section.generateDataSource()
    var sectionCache = [Int : SettingSection]()
    private(set) var sectionedItems = BehaviorRelay<[SettingSection]>(value: [])
    
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
        newRecitationList.send(newRecitationItems)
        translationList.send(translationEditions)
        newTranslationList.send(newTranslationItems)
    }
    
    required init() {
        
    }
}
