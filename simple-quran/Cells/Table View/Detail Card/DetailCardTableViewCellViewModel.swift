//
//  DetailCardTableViewCellViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import RxSwift
import RxCocoa

protocol DetailCardTableViewCellViewModelTypes {
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
    
    var detailLabelText: BehaviorRelay<String?> { get }
    var detailLabelTextFont: BehaviorRelay<UIFont> { get }
    var detailLabelTextColor: BehaviorRelay<UIColor> { get }
    var detailLabelAttributedText: BehaviorRelay<NSAttributedString?> { get }
    var detailLabelTextAlignment: BehaviorRelay<NSTextAlignment> { get }
    var detailLabelTextLine: BehaviorRelay<Int> { get }
    
    var leftButtonText: BehaviorRelay<String> { get }
    var leftButtonTextFont: BehaviorRelay<UIFont> { get }
    var leftButtonIconImage: BehaviorRelay<UIImage?> { get }
    var leftButtonTintColor: BehaviorRelay<UIColor> { get }

    var rightButtonText: BehaviorRelay<String> { get }
    var rightButtonTextFont: BehaviorRelay<UIFont> { get }
    var rightButtonIconImage: BehaviorRelay<UIImage?> { get }
    var rightButtonTintColor: BehaviorRelay<UIColor> { get }
    
    init()
}

class DetailCardTableViewCellViewModel: DetailCardTableViewCellViewModelTypes {
    let titleLabelText = BehaviorRelay<String?>(value: nil)
    let titleLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 18, weight: .bold))
    let titleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let titleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let titleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .center)
    let titleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let subtitleLabelText = BehaviorRelay<String?>(value: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ")
    let subtitleLabelTextFont = BehaviorRelay<UIFont>(value: .amiriRegular(size: 22))
    let subtitleLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let subtitleLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let subtitleLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .center)
    let subtitleLabelTextLine = BehaviorRelay<Int>(value: 0)
    
    let detailLabelText = BehaviorRelay<String?>(value: nil)
    let detailLabelTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let detailLabelTextColor = BehaviorRelay<UIColor>(value: .white)
    let detailLabelAttributedText = BehaviorRelay<NSAttributedString?>(value: nil)
    let detailLabelTextAlignment = BehaviorRelay<NSTextAlignment>(value: .center)
    let detailLabelTextLine = BehaviorRelay<Int>(value: 0)
        
    let leftButtonText = BehaviorRelay<String>(value: "Mishari Alafasy")
    let leftButtonTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let leftButtonIconImage = BehaviorRelay<UIImage?>(value: UIImage(named: "ico_soundhigh")?.withRenderingMode(.alwaysTemplate))
    let leftButtonTintColor = BehaviorRelay<UIColor>(value: .white)

    let rightButtonText = BehaviorRelay<String>(value: "Malay")
    let rightButtonTextFont = BehaviorRelay<UIFont>(value: .systemFont(ofSize: 14))
    let rightButtonIconImage = BehaviorRelay<UIImage?>(value: UIImage(named: "ico_youtube")?.withRenderingMode(.alwaysTemplate))
    let rightButtonTintColor = BehaviorRelay<UIColor>(value: .white)
    
    required init() {
        
    }
}
