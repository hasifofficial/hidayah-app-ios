//
//  PopupPanelViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class PopupPanelViewController: FloatingPanelViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panelType = .popup
    }
    
    override func viewDidLayoutSubviews() {
        panelContainer.layer.cornerRadius = 20
        panelContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if (container as? UIViewController) != nil {
            panelHeightConstraint.constant = container.preferredContentSize.height
        }
    }
    
    override func setupConstraint() {
        guard let contentVC = contentVC else { return }

        var panelViewHeight = contentVC.view.bounds.height
        let bottomSafeArea: CGFloat
        let viewCenterYAnchor: NSLayoutYAxisAnchor
        let window = UIApplication.mainWindow
        bottomSafeArea = window?.safeAreaInsets.bottom ?? 0
        viewCenterYAnchor = view.safeAreaLayoutGuide.centerYAnchor

        let maxPanelHeight = UIScreen.main.bounds.height - 20 - bottomSafeArea*2
        if panelViewHeight > maxPanelHeight {
            panelViewHeight = maxPanelHeight
        }
                
        panelHeightConstraint = panelContainer.heightAnchor.constraint(equalToConstant: panelViewHeight)

        NSLayoutConstraint.activate([
            panelContainer.centerYAnchor.constraint(equalTo: viewCenterYAnchor),
            panelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            panelHeightConstraint,
            panelView.topAnchor.constraint(equalTo: panelContainer.topAnchor),
            panelView.leadingAnchor.constraint(equalTo: panelContainer.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: panelContainer.trailingAnchor),
            panelView.bottomAnchor.constraint(equalTo: panelContainer.bottomAnchor)
        ])
    }
}
