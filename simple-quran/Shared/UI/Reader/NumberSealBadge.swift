//
//  NumberSealBadge.swift
//  simple-quran
//

import SwiftUI

/// The green seal with a white number that starts each reader row.
struct NumberSealBadge: View {
    let number: Int

    var body: some View {
        ZStack {
            Image(systemName: "seal.fill")
                .font(.system(size: 32))
                .foregroundColor(.lightGreen)

            Text("\(number)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
