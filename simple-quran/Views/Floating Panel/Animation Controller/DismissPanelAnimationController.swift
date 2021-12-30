//
//  DismissPanelAnimationController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class DismissPanelAnimationController: BaseAnimatorTransition {
    
    let interactionController: UIPercentDrivenInteractiveTransition?
    let panel: PanelType?
    
    public enum PanelType {
        case popup
        case drawer
    }
    
    init(type: TransitionType, duration: TimeInterval = 2.0, interactionController: UIPercentDrivenInteractiveTransition? = nil, panelType: PanelType? = .drawer) {
        self.interactionController = interactionController
        self.panel = panelType
        super.init(type: type, duration: duration)
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else { return }

        var floatingPanelViewController = FloatingPanelViewController()
        if let fromViewController = fromViewController as? FloatingPanelViewController {
            floatingPanelViewController = fromViewController
        }
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        floatingPanelViewController.view.frame = finalFrameForVC
        toViewController.view.alpha = 0.5

        if self.type == .navigation, let toViewController = transitionContext.viewController(forKey: .to) {
            containerView.insertSubview(toViewController.view, belowSubview: floatingPanelViewController.view)
        }
        
        let dismissYTransitionHeight = (panel == PanelType.drawer) ? floatingPanelViewController.panelContainer.bounds.height : UIScreen.main.bounds.height/2 + (floatingPanelViewController.panelContainer.bounds.height/2)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            floatingPanelViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: dismissYTransitionHeight)
            toViewController.view.alpha = 1
        }, completion: { _ in
            let cancel = transitionContext.transitionWasCancelled
            if !cancel {
                floatingPanelViewController.removeChildViewController()
            }
            transitionContext.completeTransition(!cancel)
        })
    }
}
