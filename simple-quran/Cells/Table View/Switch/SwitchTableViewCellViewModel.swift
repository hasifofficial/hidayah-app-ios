//
//  SwitchTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/9/21.
//

import RxSwift
import RxCocoa

protocol SwitchTableViewCellViewModelTypes {
    var titleLabelText: BehaviorRelay<String?> { get }
    var titleLabelTextFont: BehaviorRelay<UIFont> { get }
    var titleLabelTextColor: BehaviorRelay<UIColor> { get }
    var titleLabelTextLine: BehaviorRelay<Int> { get }

    var isSwitchOn: BehaviorRelay<Bool> { get }

    init()
}

class SwitchTableViewCellViewModel: SwitchTableViewCellViewModelTypes {
    let titleLabelText = BehaviorRelay<String?>(value: nil)
    let titleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let titleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let titleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let isSwitchOn = BehaviorRelay<Bool>(value: false)

    required init() {
        
    }
}
