//
//  DetailTitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import Combine

protocol DetailTitleTableViewCellViewModelTypes {
    var rightTitleLabelText: CurrentValueSubject<String?, Never> { get }
    var rightTitleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var rightTitleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var rightTitleLabelTextAlignment: CurrentValueSubject<NSTextAlignment, Never> { get }
    var rightTitleLabelTextLine: CurrentValueSubject<Int, Never> { get }

    var leftTitleLabelText: CurrentValueSubject<String?, Never> { get }
    var leftTitleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var leftTitleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var leftTitleLabelTextAlignment: CurrentValueSubject<NSTextAlignment, Never> { get }
    var leftTitleLabelTextLine: CurrentValueSubject<Int, Never> { get }

    var leftSubtitleLabelText: CurrentValueSubject<String?, Never> { get }
    var leftSubtitleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var leftSubtitleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var leftSubtitleLabelTextAlignment: CurrentValueSubject<NSTextAlignment, Never> { get }
    var leftSubtitleLabelTextLine: CurrentValueSubject<Int, Never> { get }
    
    init()
}

class DetailTitleTableViewCellViewModel: DetailTitleTableViewCellViewModelTypes {
    let rightTitleLabelText = CurrentValueSubject<String?, Never>(nil)
    let rightTitleLabelTextFont = CurrentValueSubject<UIFont, Never>(.kitabBold(size: 22))
    let rightTitleLabelTextColor = CurrentValueSubject<UIColor, Never>(.lightGreen)
    let rightTitleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.right)
    let rightTitleLabelTextLine = CurrentValueSubject<Int, Never>(0)

    let leftTitleLabelText = CurrentValueSubject<String?, Never>(nil)
    let leftTitleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 18, weight: .bold))
    let leftTitleLabelTextColor = CurrentValueSubject<UIColor, Never>(.white)
    let leftTitleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.left)
    let leftTitleLabelTextLine = CurrentValueSubject<Int, Never>(0)

    let leftSubtitleLabelText = CurrentValueSubject<String?, Never>(nil)
    let leftSubtitleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let leftSubtitleLabelTextColor = CurrentValueSubject<UIColor, Never>(.textGray)
    let leftSubtitleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.left)
    let leftSubtitleLabelTextLine = CurrentValueSubject<Int, Never>(0)

    required init() {
        
    }
}
