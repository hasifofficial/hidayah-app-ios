//
//  UIFont+Extension.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit

extension UIFont {
    static func amiriBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Amiri-Bold", size: size)!
    }

    static func amiriBoldItalic(size: CGFloat) -> UIFont {
        return UIFont(name: "Amiri-BoldItalic", size: size)!
    }

    static func amiriItalic(size: CGFloat) -> UIFont {
        return UIFont(name: "Amiri-Italic", size: size)!
    }

    static func amiriRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Amiri-Regular", size: size)!
    }
    
    static func kitabRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Kitab-Regular", size: size)!
    }
    
    static func kitabBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Kitab-Bold", size: size)!
    }
    
    static func loadFontsBundle(bundle: String, fontExtension: String) {
        if let bundleFileName = Bundle.main.path(forResource: bundle, ofType: "bundle") {
            let pathForResourceString = Bundle.paths(forResourcesOfType: fontExtension, inDirectory: bundleFileName)
            
            for item in pathForResourceString {
                registerFont(path: item)
            }
        } else {
            print("Couldn't find bundle name in project")
        }
    }

    static func registerFont(path: String) {
        if let fontData = NSData(contentsOfFile: path), let dataProvider = CGDataProvider(data: fontData) {
            let fontRef = CGFont(dataProvider)
            var errorRef: Unmanaged<CFError>?
            
            if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false {
                print("Failed to register font - Register graphics font failed. This font may have already been registered in the main bundle.")
            }
        } else {
            print("Failed to register font - Bundle identifier invalid.")
        }
    }
}
