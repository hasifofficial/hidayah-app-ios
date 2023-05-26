//
//  TitleWithSubtitleTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import Combine

protocol TitleWithSubtitleTableViewCellViewModelTypes {
    var titleLabelText: CurrentValueSubject<String?, Never> { get }
    var titleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var titleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var titleLabelAttributedText: CurrentValueSubject<NSAttributedString?, Never> { get }
    var titleLabelTextAlignment: CurrentValueSubject<NSTextAlignment, Never> { get }
    var titleLabelTextLine: CurrentValueSubject<Int, Never> { get }
    
    var subtitleLabelText: CurrentValueSubject<String?, Never> { get }
    var subtitleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var subtitleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var subtitleLabelAttributedText: CurrentValueSubject<NSAttributedString?, Never> { get }
    var subtitleLabelTextAlignment: CurrentValueSubject<NSTextAlignment, Never> { get }
    var subtitleLabelTextLine: CurrentValueSubject<Int, Never> { get }

    init()
}

class TitleWithSubtitleTableViewCellViewModel: TitleWithSubtitleTableViewCellViewModelTypes {
    let titleLabelText = CurrentValueSubject<String?, Never>(nil)
    let titleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let titleLabelTextColor = CurrentValueSubject<UIColor, Never>(.white)
    let titleLabelAttributedText = CurrentValueSubject<NSAttributedString?, Never>(nil)
    let titleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.natural)
    let titleLabelTextLine = CurrentValueSubject<Int, Never>(0)
    
    let subtitleLabelText = CurrentValueSubject<String?, Never>(nil)
    let subtitleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let subtitleLabelTextColor = CurrentValueSubject<UIColor, Never>(.white)
    let subtitleLabelAttributedText = CurrentValueSubject<NSAttributedString?, Never>(nil)
    let subtitleLabelTextAlignment = CurrentValueSubject<NSTextAlignment, Never>(.natural)
    let subtitleLabelTextLine = CurrentValueSubject<Int, Never>(0)
    
    required init() {
        
    }
}
