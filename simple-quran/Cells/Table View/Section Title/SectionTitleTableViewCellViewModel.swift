//
//  SectionTitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import RxSwift
import RxCocoa

protocol SectionTitleTableViewCellViewModelTypes {
    var titleLabelText: BehaviorRelay<String?> { get }
    var titleLabelTextFont: BehaviorRelay<UIFont> { get }
    var titleLabelTextColor: BehaviorRelay<UIColor> { get }
    var titleLabelAttributedText: BehaviorRelay<NSAttributedString?> { get }
    var titleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var titleLabelTextLine: BehaviorRelay<Int> { get }
    
    var rightButtonText: BehaviorRelay<String> { get }
    var rightButtonTextColor: BehaviorRelay<UIColor> { get }
    var rightButtonTextFont: BehaviorRelay<UIFont> { get }
    var rightButtonTapHandler: BehaviorRelay<(() -> Void)?> { get }
    
    var shouldHideRightButton: BehaviorRelay<Bool> { get }

    var accessoryType: BehaviorRelay<UITableViewCell.AccessoryType> { get }
    
    var containerTopSpacing: BehaviorRelay<CGFloat> { get }
    var containerBottomSpacing: BehaviorRelay<CGFloat> { get }
    var containerLeadingSpacing: BehaviorRelay<CGFloat> { get }
    var containerTrailingSpacing: BehaviorRelay<CGFloat> { get }
    
    init()
}

class SectionTitleTableViewCellViewModel: SectionTitleTableViewCellViewModelTypes {
    let titleLabelText = BehaviorRelay<String?>(value: nil)
    let titleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let titleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let titleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let titleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    let titleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let rightButtonText = BehaviorRelay<String>(value: "See All")
    let rightButtonTextColor = BehaviorRelay<UIColor>(value: .systemBlue)
    let rightButtonTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let rightButtonTapHandler = BehaviorRelay<(() -> Void)?>(value: nil)
    
    let shouldHideRightButton = BehaviorRelay<Bool>(value: true)

    let accessoryType = BehaviorRelay<UITableViewCell.AccessoryType>(value: .none)
    
    let containerTopSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerBottomSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerLeadingSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerTrailingSpacing = BehaviorRelay<CGFloat>(value: 16)
    
    required init() {
        
    }
}
