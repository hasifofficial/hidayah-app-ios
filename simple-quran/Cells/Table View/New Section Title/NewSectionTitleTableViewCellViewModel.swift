//
//  NewSectionTitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import UIKit
import Combine

class NewSectionTitleTableViewCellViewModel {
    let titleLabelText = CurrentValueSubject<String?, Never>(nil)
    let titleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let titleLabelTextColor = CurrentValueSubject<UIColor, Never>(.darkText)
    let titleLabelAttributedText = CurrentValueSubject<NSAttributedString?, Never>(nil)
    let titleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.left)
    let titleLabelTextLine = CurrentValueSubject<Int, Never>(0)
    
    let descriptionLabelText = CurrentValueSubject<String?, Never>(nil)
    let descriptionLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let descriptionLabelTextColor = CurrentValueSubject<UIColor, Never>(.lightText)
    let descriptionLabelAttributedText = CurrentValueSubject<NSAttributedString?, Never>(nil)
    let descriptionLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.left)
    let descriptionLabelTextLine = CurrentValueSubject<Int, Never>(0)
    
    let leftButtonIcon = CurrentValueSubject<UIImage?, Never>(nil)
    let leftButtonIconTintColor = CurrentValueSubject<UIColor, Never>(.darkGray)
    let leftButtonWidth = CurrentValueSubject<CGFloat, Never>(32)
    let leftButtonHeight = CurrentValueSubject<CGFloat?, Never>(nil)

    let rightButtonIcon = CurrentValueSubject<UIImage?, Never>(nil)
    let rightButtonIconTintColor = CurrentValueSubject<UIColor, Never>(.darkGray)
    
    let shouldDisableTitleLabelTap = CurrentValueSubject<Bool, Never>(true)
    let shouldDisableDecriptionLabelTap = CurrentValueSubject<Bool, Never>(true)
    let shouldHideLeftButton = CurrentValueSubject<Bool, Never>(true)
    let shouldHideRightButton = CurrentValueSubject<Bool, Never>(true)
    let shouldHideDescriptionLabel = CurrentValueSubject<Bool, Never>(true)

    let backgroundColor = CurrentValueSubject<UIColor, Never>(.clear)
    
    let containerTopSpacing = CurrentValueSubject<CGFloat, Never>(24)
    let containerBottomSpacing = CurrentValueSubject<CGFloat, Never>(24)
    let containerLeadingSpacing = CurrentValueSubject<CGFloat, Never>(24)
    let containerTrailingSpacing = CurrentValueSubject<CGFloat, Never>(24)
}
