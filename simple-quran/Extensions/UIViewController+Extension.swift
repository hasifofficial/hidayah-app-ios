//
//  UIViewController+Extension.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/11/21.
//

import UIKit
import SafariServices

extension UIViewController {
    typealias WebViewAction = ((_ webViewController: SFSafariViewController) -> Void)?
    
    func presentWebView(_ url: URL, completion: WebViewAction) {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        
        if let completion = completion {
            completion(vc)
        }
    }

    func enableSwipeToDismiss() {
        navigationController?.isModalInPresentation = false
        isModalInPresentation = false
    }

    func disableSwipeToDismiss() {
        navigationController?.isModalInPresentation = true
        isModalInPresentation = true
    }
}
