//
//  LabelWithLeftIconTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/21.
//

import RxSwift
import RxCocoa

protocol LabelWithLeftIconTableViewCellViewModelTypes {
    var titleLabelText: BehaviorRelay<String?> { get }
    var titleLabelTextFont: BehaviorRelay<UIFont> { get }
    var titleLabelTextColor: BehaviorRelay<UIColor> { get }
    var titleLabelAttributedText: BehaviorRelay<NSAttributedString?> { get }
    var titleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var titleLabelTextLine: BehaviorRelay<Int> { get }
    
    var leftImage: BehaviorRelay<UIImage?> { get }
    var leftImageTintColor: BehaviorRelay<UIColor> { get }
    
    var backgroundColor: BehaviorRelay<UIColor> { get }

    var containerTopSpacing: BehaviorRelay<CGFloat> { get }
    var containerBottomSpacing: BehaviorRelay<CGFloat> { get }
    var containerLeadingSpacing: BehaviorRelay<CGFloat> { get }
    var containerTrailingSpacing: BehaviorRelay<CGFloat> { get }
    
    init()
}

class LabelWithLeftIconTableViewCellViewModel: LabelWithLeftIconTableViewCellViewModelTypes {
    let titleLabelText = BehaviorRelay<String?>(value: nil)
    let titleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let titleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let titleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let titleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    let titleLabelTextLine = BehaviorRelay<Int>(value: 0)
        
    let leftImage = BehaviorRelay<UIImage?>(value: nil)
    let leftImageTintColor = BehaviorRelay<UIColor>(value: .white)

    let backgroundColor = BehaviorRelay<UIColor>(value: .lightGreen)
    
    let containerTopSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerBottomSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerLeadingSpacing = BehaviorRelay<CGFloat>(value: 16)
    let containerTrailingSpacing = BehaviorRelay<CGFloat>(value: 16)
    
    required init() {
        
    }
}
