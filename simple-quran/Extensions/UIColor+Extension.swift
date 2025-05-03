//
//  UIColor+Extension.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit

extension UIColor {
    static var lightGreen: UIColor {
        return hexStringToUIColor("#47B881")
    }
    
    static var textGray: UIColor {
        return hexStringToUIColor("#8A8A8C")
    }

    static var backgroundLightGray: UIColor {
        return hexStringToUIColor("#F9F9F9")
    }
    
    static var backgroundLightGrayDarkMode: UIColor {
        return hexStringToUIColor("#3B3B3B")
    }
    
    static var placeholderGray: UIColor {
        return hexStringToUIColor("#AAAAAA").withAlphaComponent(0.2)
    }
    
    static var title: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .black
            }
        }
    }
    
    static var backgroundGray: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .backgroundLightGrayDarkMode
            default:
                return .backgroundLightGray
            }
        }
    }
    
    static func hexStringToUIColor(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return cString.count != 6
            ? UIColor.gray
            : UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
    }
}
