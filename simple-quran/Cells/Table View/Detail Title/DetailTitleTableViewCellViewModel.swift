//
//  DetailTitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import RxSwift
import RxCocoa

protocol DetailTitleTableViewCellViewModelTypes {
    var rightTitleLabelText: BehaviorRelay<String?> { get }
    var rightTitleLabelTextFont: BehaviorRelay<UIFont> { get }
    var rightTitleLabelTextColor: BehaviorRelay<UIColor> { get }
    var rightTitleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var rightTitleLabelTextLine: BehaviorRelay<Int> { get }

    var leftTitleLabelText: BehaviorRelay<String?> { get }
    var leftTitleLabelTextFont: BehaviorRelay<UIFont> { get }
    var leftTitleLabelTextColor: BehaviorRelay<UIColor> { get }
    var leftTitleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var leftTitleLabelTextLine: BehaviorRelay<Int> { get }

    var leftSubtitleLabelText: BehaviorRelay<String?> { get }
    var leftSubtitleLabelTextFont: BehaviorRelay<UIFont> { get }
    var leftSubtitleLabelTextColor: BehaviorRelay<UIColor> { get }
    var leftSubtitleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var leftSubtitleLabelTextLine: BehaviorRelay<Int> { get }
    
    init()
}

class DetailTitleTableViewCellViewModel: DetailTitleTableViewCellViewModelTypes {
    let rightTitleLabelText = BehaviorRelay<String?>(value: nil)
    let rightTitleLabelTextFont = BehaviorRelay<UIFont>(value: .kitabBold(size: 22))
    let rightTitleLabelTextColor = BehaviorRelay<UIColor>(value: .lightGreen)
    let rightTitleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .right)
    let rightTitleLabelTextLine = BehaviorRelay<Int>(value: 0)

    let leftTitleLabelText = BehaviorRelay<String?>(value: nil)
    let leftTitleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 18, weight: .bold))
    let leftTitleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let leftTitleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .left)
    let leftTitleLabelTextLine = BehaviorRelay<Int>(value: 0)

    let leftSubtitleLabelText = BehaviorRelay<String?>(value: nil)
    let leftSubtitleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let leftSubtitleLabelTextColor = BehaviorRelay<UIColor>(value: .textGray)
    let leftSubtitleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .left)
    let leftSubtitleLabelTextLine = BehaviorRelay<Int>(value: 0)

    required init() {
        
    }
}
