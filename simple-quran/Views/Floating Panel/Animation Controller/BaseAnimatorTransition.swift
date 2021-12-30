//
//  BaseAnimatorTransition.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class BaseAnimatorTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case navigation
        case modal
    }
    
    private(set) var type: TransitionType
    private(set) var duration: TimeInterval
    
    init(type: TransitionType, duration: TimeInterval = 2.0) {
        self.type = type
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError("You have to implement this method for yourself")
    }
}
