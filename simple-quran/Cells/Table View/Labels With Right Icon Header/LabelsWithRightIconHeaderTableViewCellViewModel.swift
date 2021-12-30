//
//  LabelsWithRightIconHeaderTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/21.
//

import RxSwift
import RxCocoa

protocol LabelsWithRightIconHeaderTableViewCellViewModelTypes {
    var topLabelText: BehaviorRelay<String?> { get }
    var topLabelTextFont: BehaviorRelay<UIFont> { get }
    var topLabelTextColor: BehaviorRelay<UIColor> { get }
    var topLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    
    var middleLabelText: BehaviorRelay<String?> { get }
    var middleLabelTextFont: BehaviorRelay<UIFont> { get }
    var middleLabelTextColor: BehaviorRelay<UIColor> { get }
    var middleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }

    var bottomLabelText: BehaviorRelay<String?> { get }
    var bottomLabelTextFont: BehaviorRelay<UIFont> { get }
    var bottomLabelTextColor: BehaviorRelay<UIColor> { get }
    var bottomLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    
    var rightImage: BehaviorRelay<UIImage?> { get }
    
    var backgroundColor: BehaviorRelay<UIColor> { get }

    var containerTopSpacing: BehaviorRelay<CGFloat> { get }
    var containerBottomSpacing: BehaviorRelay<CGFloat> { get }
    var containerLeadingSpacing: BehaviorRelay<CGFloat> { get }
    var containerTrailingSpacing: BehaviorRelay<CGFloat> { get }
    
    init()
}

class LabelsWithRightIconHeaderTableViewCellViewModel: LabelsWithRightIconHeaderTableViewCellViewModelTypes {
    let topLabelText = BehaviorRelay<String?>(value: nil)
    let topLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let topLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let topLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)

    let middleLabelText = BehaviorRelay<String?>(value: nil)
    let middleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 23, weight: .bold))
    let middleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let middleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)

    let bottomLabelText = BehaviorRelay<String?>(value: nil)
    let bottomLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let bottomLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let bottomLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    
    let rightImage = BehaviorRelay<UIImage?>(value: nil)

    let backgroundColor = BehaviorRelay<UIColor>(value: .lightGreen)
    
    let containerTopSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerBottomSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerLeadingSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerTrailingSpacing = BehaviorRelay<CGFloat>(value: 16)
    
    required init() {
        
    }
}
