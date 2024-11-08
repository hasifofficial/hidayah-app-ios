//
//  UIApplication+Extension.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

extension UIApplication {
    static var mainWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    }
}
