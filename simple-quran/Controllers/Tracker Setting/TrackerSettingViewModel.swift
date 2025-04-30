//
//  TrackerSettingViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/2/25.
//

import Combine
import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol TrackerSettingViewModelTypes: SectionSetter, TableViewSectionSetter where Section == TrackerSettingSection {
    var title: CurrentValueSubject<String, Never> { get }
    var trackerHistoryTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var trackerHistoryCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var categoryTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var manageCategoryCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var resetDailyProgressCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var resetAllCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> { get }
    var tapAction: CurrentValueSubject<Action<Section.Item, Never>, Never> { get }

    init()
}

class TrackerSettingViewModel: TrackerSettingViewModelTypes {
    let title = CurrentValueSubject<String, Never>(NSLocalizedString(
        "setting_tracker_header_title",
        comment: ""
    ))
    
    var trackerHistoryTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString(
                "setting_tracker_history_title",
                comment: ""
            ),
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.title
            ]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.send(attributedText)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var trackerHistoryCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString(
            "setting_tracker_pass_history_title",
            comment: ""
        ))
        vm.leftButtonIcon.send(UIImage(systemName: "checkmark.arrow.trianglehead.counterclockwise")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.shouldHideLeftButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var categoryTitleCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString(
                "setting_tracker_category_title",
                comment: ""
            ),
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.title
            ]
        )
        
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelAttributedText.send(attributedText)
        vm.containerTopSpacing.send(24)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var manageCategoryCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString(
            "setting_tracker_manage_category_title",
            comment: ""
        ))
        vm.leftButtonIcon.send(UIImage(systemName: "square.grid.2x2")?.withRenderingMode(.alwaysTemplate))
        vm.leftButtonIconTintColor.send(.title)
        vm.shouldHideLeftButton.send(false)
        vm.accessoryType.send(.disclosureIndicator)
        vm.containerTopSpacing.send(8)
        vm.containerBottomSpacing.send(0)

        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    var resetDailyProgressCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString(
            "setting_tracker_reset_daily_progress_title",
            comment: ""
        ))
        vm.titleLabelTextColor.send(.red)
        vm.rightButtonIcon.send(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate))
        vm.rightButtonIconTintColor.send(.red)
        vm.shouldHideRightButton.send(false)
        vm.containerTopSpacing.send(48)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()
    
    var resetAllCell: CurrentValueSubject<SectionTitleTableViewCellViewModel, Never> = {
        let vm = SectionTitleTableViewCellViewModel()
        
        vm.titleLabelText.send(NSLocalizedString(
            "setting_tracker_reset_all_title",
            comment: "")
        )
        vm.titleLabelTextColor.send(.red)
        vm.rightButtonIcon.send(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate))
        vm.rightButtonIconTintColor.send(.red)
        vm.shouldHideRightButton.send(false)
        vm.containerTopSpacing.send(16)
        vm.containerBottomSpacing.send(0)
        
        return CurrentValueSubject<SectionTitleTableViewCellViewModel, Never>(vm)
    }()

    let tapAction = CurrentValueSubject<Action<Section.Item, Swift.Never>, Never>(Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<TrackerSettingSection> = Section.generateDataSource()
    var sectionCache = [Int : TrackerSettingSection]()
    private(set) var sectionedItems = BehaviorRelay<[TrackerSettingSection]>(value: [])

    required init() {
        
    }
}
