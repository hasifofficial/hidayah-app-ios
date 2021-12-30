//
//  FloatingPanelViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class FloatingPanelViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    weak var parentVC: UIViewController?
    
    var contentVC: UIViewController?
    var panelHeightConstraint: NSLayoutConstraint!
    var maxPanelHeightAllowable: CGFloat = UIScreen.main.bounds.height
    var panelContainer: UIView!
    var panelView: UIView!
    var interactionController: SwipeInteractionController?
    var panelType: DismissPanelAnimationController.PanelType?
    var isPresenting = false
    var tapOutsideToDismiss: Bool = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(parentVC: UIViewController, contentVC: UIViewController, tapOutsideToDismiss: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        self.contentVC = contentVC
        self.tapOutsideToDismiss = tapOutsideToDismiss
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraint()
        addChildViewController()
        
        self.interactionController = SwipeInteractionController(viewController: self, isSwippable: tapOutsideToDismiss)
    }
    
    @objc func closeHandler(_ notification: Notification) {
        guard let closure = notification.object as? (() -> Void) else { return }
        close(closure)
    }
    
    func setupViews() {
        panelContainer = UIView()
        panelContainer.translatesAutoresizingMaskIntoConstraints = false
        panelContainer.clipsToBounds = true
        if #available(iOS 13.0, *) {
            panelContainer.backgroundColor = .systemBackground
        } else {
            panelContainer.backgroundColor = .white
        }
        view.addSubview(panelContainer)
        
        panelView = UIView()
        panelView.translatesAutoresizingMaskIntoConstraints = false
        panelView.clipsToBounds = true
        panelContainer.addSubview(panelView)
    }
    
    func setupConstraint() {}
    
    private func addChildViewController() {
        guard let contentVC = contentVC else { return }
        
        addChild(contentVC)
        contentVC.view.frame = panelView.bounds
        panelView.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)
    }
    
    func removeChildViewController() {
        guard let contentVC = contentVC else { return }
        
        contentVC.willMove(toParent: nil)
        contentVC.view.removeFromSuperview()
        contentVC.removeFromParent()
    }
    
    @objc func close(_ completion: (() -> Void)? = nil) {
        guard let parentVC = parentVC else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            
            parentVC.dismiss(animated: true) { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.parentVC = nil
                strongSelf.contentVC = nil
                strongSelf.removeChildViewController()
                
                completion?()
            }
        }
    }
    
    func show() {
        guard let parentVC = parentVC else { return }
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            parentVC.present(strongSelf, animated: true, completion: nil)
        }
    }
    
    // Transitioning between 2 child vc
    func cycleFromViewController(toViewController: UIViewController) {
        if let contentVC = contentVC {
            contentVC.willMove(toParent: nil)
            addChild(toViewController)
            self.panelHeightConstraint.constant = toViewController.view.bounds.height
            toViewController.view.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.view.layoutIfNeeded()
                strongSelf.panelView.addSubview(toViewController.view)
                toViewController.view.alpha = 1
                contentVC.view.alpha = 0
            }, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                contentVC.view.removeFromSuperview()
                contentVC.removeFromParent()
                toViewController.didMove(toParent: strongSelf)
                strongSelf.contentVC = toViewController
            })
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.view, touch == view && tapOutsideToDismiss else { return }
        
        close()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        
        return PresentPanelAnimationController(type: .modal, duration: 0.33)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var interactionController: UIPercentDrivenInteractiveTransition?
        if let viewController = dismissed as? FloatingPanelViewController {
            interactionController = viewController.interactionController
        }
        
        isPresenting = false
        
        return DismissPanelAnimationController(type: .modal, duration: 0.16, interactionController: interactionController, panelType: panelType)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? DismissPanelAnimationController,
            let interactionController = animator.interactionController as? SwipeInteractionController,
            interactionController.interactionInProgress else { return nil }
        return interactionController
    }
}
