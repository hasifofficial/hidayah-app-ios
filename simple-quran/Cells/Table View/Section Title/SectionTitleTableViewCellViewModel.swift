//
//  SectionTitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit
import Combine

protocol SectionTitleTableViewCellViewModelTypes {
    var titleLabelText: CurrentValueSubject<String?, Never> { get }
    var titleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var titleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var titleLabelAttributedText: CurrentValueSubject<NSAttributedString?, Never> { get }
    var titleLabelTextAlignment: CurrentValueSubject<NSTextAlignment, Never> { get }
    var titleLabelTextLine: CurrentValueSubject<Int, Never> { get }
    
    var rightButtonText: CurrentValueSubject<String, Never> { get }
    var rightButtonTextColor: CurrentValueSubject<UIColor, Never> { get }
    var rightButtonTextFont: CurrentValueSubject<UIFont, Never> { get }
    var rightButtonTapHandler: CurrentValueSubject<(() -> Void)?, Never> { get }
    
    var shouldHideRightButton: CurrentValueSubject<Bool, Never> { get }

    var accessoryType: CurrentValueSubject<UITableViewCell.AccessoryType, Never> { get }
    
    var containerTopSpacing: CurrentValueSubject<CGFloat, Never> { get }
    var containerBottomSpacing: CurrentValueSubject<CGFloat, Never> { get }
    var containerLeadingSpacing: CurrentValueSubject<CGFloat, Never> { get }
    var containerTrailingSpacing: CurrentValueSubject<CGFloat, Never> { get }
    
    init()
}

class SectionTitleTableViewCellViewModel: SectionTitleTableViewCellViewModelTypes {
    let titleLabelText = CurrentValueSubject<String?, Never>(nil)
    let titleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let titleLabelTextColor = CurrentValueSubject<UIColor, Never>(.white)
    let titleLabelAttributedText = CurrentValueSubject<NSAttributedString?, Never>(nil)
    let titleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.natural)
    let titleLabelTextLine = CurrentValueSubject<Int, Never>(0)
    
    let rightButtonText = CurrentValueSubject<String, Never>("See All")
    let rightButtonTextColor = CurrentValueSubject<UIColor, Never>(.systemBlue)
    let rightButtonTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let rightButtonTapHandler = CurrentValueSubject<(() -> Void)?, Never>(nil)
    
    let shouldHideRightButton = CurrentValueSubject<Bool, Never>(true)

    let accessoryType = CurrentValueSubject<UITableViewCell.AccessoryType, Never>(.none)
    
    let containerTopSpacing = CurrentValueSubject<CGFloat, Never>(16)
    let containerBottomSpacing = CurrentValueSubject<CGFloat, Never>(16)
    let containerLeadingSpacing = CurrentValueSubject<CGFloat, Never>(16)
    let containerTrailingSpacing = CurrentValueSubject<CGFloat, Never>(16)
    
    required init() {
        
    }
}
