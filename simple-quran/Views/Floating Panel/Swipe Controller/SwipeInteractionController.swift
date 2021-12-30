//
//  SwipeInteractionController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    private weak var floatingPanelViewController: FloatingPanelViewController!
    private var isSwippable: Bool!
    
    init(viewController: UIViewController, isSwippable: Bool = true) {
        super.init()
        self.viewController = viewController
        self.isSwippable = isSwippable
        setupGestureRecognizer(in: viewController.view)
        if let viewController = self.viewController as? FloatingPanelViewController {
            floatingPanelViewController = viewController
        }
    }
    
    private func setupGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        gesture.isEnabled = isSwippable
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let height = floatingPanelViewController.panelContainer.bounds.height
        var percent = translation.y / height
        percent = CGFloat(fminf(fmaxf(Float(percent), 0.0), 1.0))

        switch gesture.state {
        case .began:
            interactionInProgress = true
            if let navigationController = viewController.navigationController {
                navigationController.popViewController(animated: true)
                return
            }
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = percent > 0.5
            update(percent)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            shouldCompleteTransition ? finish() : cancel()
        default:
            break
        }
    }
}
