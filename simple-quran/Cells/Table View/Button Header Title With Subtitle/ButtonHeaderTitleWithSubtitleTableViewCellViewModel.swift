//
//  ButtonHeaderTitleWithSubtitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import RxSwift
import RxCocoa

protocol ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes {
    var circleNumberText: BehaviorRelay<String?> { get }
    var circleNumberTextFont: BehaviorRelay<UIFont> { get }
    var circleNumberTextColor: BehaviorRelay<UIColor> { get }
    var circleNumberTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var circleViewBackgroundColor: BehaviorRelay<UIColor> { get }
    
    var rightHeaderButtonImage: BehaviorRelay<UIImage?> { get }
    var rightHeaderButtonImageTintColor: BehaviorRelay<UIColor> { get }
    
    var centerHeaderButtonImage: BehaviorRelay<UIImage?> { get }
    var centerHeaderButtonImageTintColor: BehaviorRelay<UIColor> { get }

    var leftHeaderButtonImage: BehaviorRelay<UIImage?> { get }
    var leftHeaderButtonImageTintColor: BehaviorRelay<UIColor> { get }
    
    var headerViewBackgroundColor: BehaviorRelay<UIColor> { get }
    var headerViewBackgroundColorDarkMode: BehaviorRelay<UIColor> { get }

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
    
    var shouldHideSubtitle: BehaviorRelay<Bool> { get }
    
    var data: BehaviorRelay<Any?> { get }
    
    init()
}

class ButtonHeaderTitleWithSubtitleTableViewCellViewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes {
    let circleNumberText = BehaviorRelay<String?>(value: nil)
    let circleNumberTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let circleNumberTextColor = BehaviorRelay<UIColor>(value: .white)
    let circleNumberTextAlignment = BehaviorRelay<NSTextAlignment>(value: .center)
    let circleViewBackgroundColor = BehaviorRelay<UIColor>(value: .lightGreen)
    
    let rightHeaderButtonImage = BehaviorRelay<UIImage?>(value: UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate))
    let rightHeaderButtonImageTintColor = BehaviorRelay<UIColor>(value: .lightGreen)

    let centerHeaderButtonImage = BehaviorRelay<UIImage?>(value: UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate))
    let centerHeaderButtonImageTintColor = BehaviorRelay<UIColor>(value: .lightGreen)

    let leftHeaderButtonImage = BehaviorRelay<UIImage?>(value: UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate))
    let leftHeaderButtonImageTintColor = BehaviorRelay<UIColor>(value: .lightGreen)
    
    let headerViewBackgroundColor = BehaviorRelay<UIColor>(value: .backgroundLightGray)
    let headerViewBackgroundColorDarkMode = BehaviorRelay<UIColor>(value: .backgroundLightGrayDarkMode)

    let titleLabelText = BehaviorRelay<String?>(value: nil)
    let titleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let titleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let titleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let titleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    let titleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let subtitleLabelText = BehaviorRelay<String?>(value: nil)
    let subtitleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let subtitleLabelTextColor = BehaviorRelay<UIColor>(value: .textGray)
    let subtitleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let subtitleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .natural)
    let subtitleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let shouldHideSubtitle = BehaviorRelay<Bool>(value: false)
    
    let data = BehaviorRelay<Any?>(value: nil)
        
    required init() {
        
    }
}
