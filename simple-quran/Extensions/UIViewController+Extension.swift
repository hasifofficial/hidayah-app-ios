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
        if #available(iOS 11.0, *) {
            let config = SFSafariViewController.Configuration()
            let vc = SFSafariViewController(url: url, configuration: config)
            
            if let completion = completion {
                completion(vc)
            }
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
