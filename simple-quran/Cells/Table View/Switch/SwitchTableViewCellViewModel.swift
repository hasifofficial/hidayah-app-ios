//
//  SwitchTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/9/21.
//

import UIKit
import Combine

protocol SwitchTableViewCellViewModelTypes {
    var titleLabelText: CurrentValueSubject<String?, Never> { get }
    var titleLabelTextFont: CurrentValueSubject<UIFont, Never> { get }
    var titleLabelTextColor: CurrentValueSubject<UIColor, Never> { get }
    var titleLabelTextLine: CurrentValueSubject<Int, Never> { get }

    var isSwitchOn: CurrentValueSubject<Bool, Never> { get }

    init()
}

class SwitchTableViewCellViewModel: SwitchTableViewCellViewModelTypes {
    let titleLabelText = CurrentValueSubject<String?, Never>(nil)
    let titleLabelTextFont = CurrentValueSubject<UIFont, Never>(.systemFont(ofSize: 14))
    let titleLabelTextColor = CurrentValueSubject<UIColor, Never>(.white)
    let titleLabelTextLine = CurrentValueSubject<Int, Never>(0)
    
    let isSwitchOn = CurrentValueSubject<Bool, Never>(false)

    required init() {
        
    }
}
