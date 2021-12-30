//
//  SettingViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol SettingViewModelTypes: SectionSetter, TableViewSectionSetter where Section == SettingSection {
    var title: BehaviorRelay<String> { get }
    var quranSettingTitleCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var recitationCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var translationLanguageCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var notificationSettingTitleCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var kahfRemnderCell: BehaviorRelay<SwitchTableViewCellViewModel> { get }
    var supportTitleCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var aboutCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var privacyCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var termConditionCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var feedbackCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var versionCell: BehaviorRelay<SectionTitleTableViewCellViewModel> { get }
    var reciterDrawer: BehaviorRelay<PickerDrawerViewModel?> { get }
    var translateLanguageDrawer: BehaviorRelay<PickerDrawerViewModel?> { get }
    var recitationList: BehaviorRelay<[EditionResponse]?> { get }
    var translationList: BehaviorRelay<[EditionResponse]?> { get }
    var tapAction: BehaviorRelay<Action<Section.Item, Never>> { get }
    
    func handleEditionSuccess(value: Edition)
    
    init()
}

class SettingViewModel: SettingViewModelTypes {
    var quranSettingTitleCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_quran_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.accept(attributedText)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()

    var recitationCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {        
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let reciterName = selectedRecitationData?.englishName ?? "Alafasy"

        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_quran_recitation_title", comment: ""))
        vm.rightButtonText.accept(reciterName)
        vm.rightButtonTextColor.accept(.textGray)
        vm.shouldHideRightButton.accept(false)
        vm.accessoryType.accept(.disclosureIndicator)
        vm.containerTopSpacing.accept(8)
        vm.containerBottomSpacing.accept(0)

        return BehaviorRelay(value: vm)
    }()

    var translationLanguageCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        var language = "English"
        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        if let translatedLanguage = selectedTranslationData?.language {
            language = Constants.getLanguageFromCode(code: translatedLanguage)
        }
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_quran_translation_title", comment: ""))
        vm.rightButtonText.accept(language)
        vm.rightButtonTextColor.accept(.textGray)
        vm.shouldHideRightButton.accept(false)
        vm.accessoryType.accept(.disclosureIndicator)
        vm.containerTopSpacing.accept(8)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()

    var notificationSettingTitleCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_notification_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.accept(attributedText)
        vm.containerTopSpacing.accept(24)
        vm.containerBottomSpacing.accept(8)

        return BehaviorRelay(value: vm)
    }()
    
    var kahfRemnderCell: BehaviorRelay<SwitchTableViewCellViewModel> = {
        let isSwitchOn = Storage.load(key: .allowKahfReminder) as? Bool ?? true
        let vm = SwitchTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_notification_alkahf_title", comment: ""))
        vm.isSwitchOn.accept(isSwitchOn)
        
        return BehaviorRelay(value: vm)
    }()
    
    var supportTitleCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("setting_support_section_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.accept(attributedText)
        vm.containerTopSpacing.accept(24)
        vm.containerBottomSpacing.accept(0)

        return BehaviorRelay(value: vm)
    }()
    
    var aboutCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_support_about_title", comment: ""))
        vm.accessoryType.accept(.disclosureIndicator)
        vm.containerTopSpacing.accept(8)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()

    var privacyCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_support_privacy_title", comment: ""))
        vm.accessoryType.accept(.disclosureIndicator)
        vm.containerTopSpacing.accept(8)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()
    
    var termConditionCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_support_term_title", comment: ""))
        vm.accessoryType.accept(.disclosureIndicator)
        vm.containerTopSpacing.accept(8)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()
    
    var feedbackCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.accept(NSLocalizedString("setting_support_feedback_title", comment: ""))
        vm.accessoryType.accept(.disclosureIndicator)
        vm.containerTopSpacing.accept(8)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()
    
    var versionCell: BehaviorRelay<SectionTitleTableViewCellViewModel> = {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"

        let attributedText = NSMutableAttributedString(
            string: String(format: NSLocalizedString("setting_app_verison", comment: ""), appVersion, buildNumber),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.accept(attributedText)
        vm.containerTopSpacing.accept(16)
        vm.containerBottomSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()
    
    let title = BehaviorRelay<String>(value: NSLocalizedString("setting_header_title", comment: ""))
    let reciterDrawer = BehaviorRelay<PickerDrawerViewModel?>(value: nil)
    let translateLanguageDrawer = BehaviorRelay<PickerDrawerViewModel?>(value: nil)
    let recitationList = BehaviorRelay<[EditionResponse]?>(value: nil)
    let translationList = BehaviorRelay<[EditionResponse]?>(value: nil)
    let tapAction = BehaviorRelay<Action<Section.Item, Swift.Never>>(value: Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<SettingSection> = Section.generateDataSource()
    var sectionCache = [Int : SettingSection]()
    private(set) var sectionedItems = BehaviorRelay<[SettingSection]>(value: [])
    
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
