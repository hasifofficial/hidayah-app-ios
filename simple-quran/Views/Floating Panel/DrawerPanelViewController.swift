//
//  DrawerPanelViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class DrawerPanelViewController: FloatingPanelViewController {
    
    private var bottomPanelContainerConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panelType = .drawer
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            panelContainer.layer.cornerRadius = 20
            panelContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            panelContainer.roundCorners([.topLeft, .topRight], radius: 20)
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if (container as? UIViewController) != nil {
            if container.preferredContentSize.height <= maxPanelHeightAllowable {
                panelHeightConstraint.constant = container.preferredContentSize.height
            } else {
                panelHeightConstraint.constant = maxPanelHeightAllowable
            }
        }
    }
    
    override func setupConstraint() {
        bottomPanelContainerConstraint = panelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        guard let contentVC = contentVC else { return }
        var panelViewHeight = contentVC.view.bounds.height
        let bottomSafeArea: CGFloat
        
        let padding: CGFloat = 40
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.mainWindow
            bottomSafeArea = window?.safeAreaInsets.bottom ?? 0
        } else {
            bottomSafeArea = bottomLayoutGuide.length
        }
        
        let maxPanelHeight = UIScreen.main.bounds.height - 20 - bottomSafeArea * 2
        if panelViewHeight > maxPanelHeight {
            panelViewHeight = maxPanelHeight
        }
        
        panelHeightConstraint = panelView.heightAnchor.constraint(equalToConstant: panelViewHeight)
        
        NSLayoutConstraint.activate([
            panelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanelContainerConstraint,
            panelView.topAnchor.constraint(equalTo: panelContainer.topAnchor),
            panelView.leadingAnchor.constraint(equalTo: panelContainer.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: panelContainer.trailingAnchor),
            panelView.bottomAnchor.constraint(equalTo: panelContainer.bottomAnchor, constant: -(bottomSafeArea + padding)),
            panelHeightConstraint
        ])
    }
}
