//
//  TitleWithSubtitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import RxSwift
import RxCocoa

protocol TitleWithSubtitleTableViewCellViewModelTypes {
    var titleLabelText: BehaviorRelay<String?> { get }
    var titleLabelTextFont: BehaviorRelay<UIFont> { get }
    var titleLabelTextColor: BehaviorRelay<UIColor> { get }
    var titleLabelAttributedText: BehaviorRelay<NSAttributedString?> { get }
    var titleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var titleLabelTextLine: BehaviorRelay<Int> { get }
    
    var subtitleLabelText: BehaviorRelay<String?> { get }
    var subtitleLabelTextFont: BehaviorRelay<UIFont> { get }
    var subtitleLabelTextColor: BehaviorRelay<UIColor> { get }
    var subtitleLabelAttributedText: BehaviorRelay<NSAttributedString?> { get }
    var subtitleLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var subtitleLabelTextLine: BehaviorRelay<Int> { get }

    init()
}

class TitleWithSubtitleTableViewCellViewModel: TitleWithSubtitleTableViewCellViewModelTypes {
    let titleLabelText = BehaviorRelay<String?>(value: nil)
    let titleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let titleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let titleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let titleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    let titleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let subtitleLabelText = BehaviorRelay<String?>(value: nil)
    let subtitleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let subtitleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let subtitleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let subtitleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    let subtitleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    required init() {
        
    }
}
