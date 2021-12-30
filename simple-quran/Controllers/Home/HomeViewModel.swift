//
//  HomeViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import Action
import RxSwift
import RxCocoa
import RxDataSources

protocol HomeViewModelTypes: SectionSetter, TableViewSectionSetter where Section == HomeSection {
    var prayerTimeCell: BehaviorRelay<LabelsWithRightIconHeaderTableViewCellViewModel?> { get }
    var dateCell: BehaviorRelay<LabelWithLeftIconTableViewCellViewModel?> { get }
    var locationCell: BehaviorRelay<LabelWithLeftIconTableViewCellViewModel?> { get }
    var tapAction: BehaviorRelay<Action<Section.Item, Never>> { get }
    
    func handleSuccess(value: PrayerTime)
    
    init()
}

class HomeViewModel: HomeViewModelTypes {
    let prayerTimeCell: BehaviorRelay<LabelsWithRightIconHeaderTableViewCellViewModel?> = {
        let vm = LabelsWithRightIconHeaderTableViewCellViewModel()
        
        vm.rightImage.accept(UIImage(named: "ico_asar"))
        vm.topLabelText.accept("Next, Asar")
        vm.middleLabelText.accept("4:31 PM")
        vm.bottomLabelText.accept("Starts in 00:00:00")

        return BehaviorRelay(value: vm)
    }()
    
    let dateCell = BehaviorRelay<LabelWithLeftIconTableViewCellViewModel?>(value: nil)
    
    let locationCell: BehaviorRelay<LabelWithLeftIconTableViewCellViewModel?> = {
        let vm = LabelWithLeftIconTableViewCellViewModel()
        
        vm.leftImage.accept(UIImage(named: "ico_location")?.withRenderingMode(.alwaysTemplate))
        vm.titleLabelText.accept("Puncak Alam")
        vm.containerTopSpacing.accept(0)
        
        return BehaviorRelay(value: vm)
    }()
    
    let tapAction = BehaviorRelay<Action<Section.Item, Swift.Never>>(value: Action { _ in
        return Observable.empty()
    })

    var dataSource: RxTableViewSectionedReloadDataSource<HomeSection> = Section.generateDataSource()
    var sectionCache = [Int : HomeSection]()
    private(set) var sectionedItems = BehaviorRelay<[HomeSection]>(value: [])
    
    func handleSuccess(value: PrayerTime) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"

        guard let prayerTimeResponse = value.data,
              let fajrTimeString = prayerTimeResponse.timings?.Fajr,
              let dhuhrTimeString = prayerTimeResponse.timings?.Dhuhr,
              let asrTimeString = prayerTimeResponse.timings?.Asr,
              let maghribTimeString = prayerTimeResponse.timings?.Maghrib,
              let ishaTimeString = prayerTimeResponse.timings?.Isha,
              let fajrTime = dateFormatter.date(from: fajrTimeString),
              let dhuhrTime = dateFormatter.date(from: dhuhrTimeString),
              let asrTime = dateFormatter.date(from: asrTimeString),
              let maghribTime = dateFormatter.date(from: maghribTimeString),
              let ishaTime = dateFormatter.date(from: ishaTimeString),
              let dayGregorian = prayerTimeResponse.date?.gregorian?.day,
              let monthGregorian = prayerTimeResponse.date?.gregorian?.month?.en,
              let yearGregorian = prayerTimeResponse.date?.gregorian?.year,
              let dayHijri = prayerTimeResponse.date?.hijri?.day,
              let monthHijri = prayerTimeResponse.date?.hijri?.month?.en,
              let yearHijri = prayerTimeResponse.date?.hijri?.year else { return }
        
        let tempPrayerTimeCell = LabelsWithRightIconHeaderTableViewCellViewModel()
        dateFormatter.dateFormat = "h:mm a"
        
        if Date().compare(ishaTime) == .orderedDescending {
            tempPrayerTimeCell.rightImage.accept(UIImage(named: "ico_isyak"))
            tempPrayerTimeCell.topLabelText.accept("Next, Isha")
            tempPrayerTimeCell.middleLabelText.accept(dateFormatter.string(from: ishaTime))
        }
        
        if Date().compare(maghribTime) == .orderedDescending {
            tempPrayerTimeCell.rightImage.accept(UIImage(named: "ico_maghrib"))
            tempPrayerTimeCell.topLabelText.accept("Next, Maghrib")
            tempPrayerTimeCell.middleLabelText.accept(dateFormatter.string(from: maghribTime))
        }

        if Date().compare(asrTime) == .orderedDescending {
            tempPrayerTimeCell.rightImage.accept(UIImage(named: "ico_asar"))
            tempPrayerTimeCell.topLabelText.accept("Next, Asr")
            tempPrayerTimeCell.middleLabelText.accept(dateFormatter.string(from: asrTime))
        }

        if Date().compare(dhuhrTime) == .orderedDescending {
            tempPrayerTimeCell.rightImage.accept(UIImage(named: "ico_zohor"))
            tempPrayerTimeCell.topLabelText.accept("Next, Dhuhr")
            tempPrayerTimeCell.middleLabelText.accept(dateFormatter.string(from: dhuhrTime))
        }

        if Date().compare(fajrTime) == .orderedDescending {
            tempPrayerTimeCell.rightImage.accept(UIImage(named: "ico_subuh"))
            tempPrayerTimeCell.topLabelText.accept("Next, Fajr")
            tempPrayerTimeCell.middleLabelText.accept(dateFormatter.string(from: fajrTime))
        }

        
        let tempDateCell = LabelWithLeftIconTableViewCellViewModel()
        tempDateCell.leftImage.accept(UIImage(named: "ico_calendar")?.withRenderingMode(.alwaysTemplate))
        tempDateCell.titleLabelText.accept("\(dayGregorian) \(monthGregorian) \(yearGregorian) / \(dayHijri) \(monthHijri) \(yearHijri)H")
        tempDateCell.containerTopSpacing.accept(0)
        tempDateCell.containerBottomSpacing.accept(8)

        prayerTimeCell.accept(tempPrayerTimeCell)
        dateCell.accept(tempDateCell)
        
//        print(prayerTimeResponse)
    }
            
    required init() {
        
    }
}
