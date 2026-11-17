//
//  FeatureIcon.swift
//  simple-quran
//

import SwiftUI

/// A feature's icon: an asset image when one is given (such as the Tasbih
/// icon from the tab bar), otherwise an SF Symbol.
struct FeatureIcon: View {
    let systemName: String
    var assetName: String? = nil
    let size: CGFloat

    var body: some View {
        if let assetName {
            Image(assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.45, height: size * 1.45)
                .foregroundColor(.lightGreen)
        } else {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(.lightGreen)
        }
    }
}
