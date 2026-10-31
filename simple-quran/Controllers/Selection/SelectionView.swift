//
//  SelectionView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import SwiftUI

struct SelectionView: View {
    let title: String
    let items: [ItemSelector]
    let selectedValue: String?
    let onSelect: (ItemSelector) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                }
                .modifier(SelectionCloseButtonStyle())

                Spacer()

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Spacer()

                Color.clear
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            List(items.indices, id: \.self) { index in
                let item = items[index]

                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(item.title)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)

                        Spacer(minLength: 8)

                        Image(
                            systemName: item.value == selectedValue
                                ? "circle.fill"
                                : "circle"
                        )
                        .foregroundColor(
                            item.value == selectedValue
                                ? .lightGreen
                                : .textGray
                        )
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
        .background(.appBackground)
        .interactiveDismissDisabled()
    }
}

private struct SelectionCloseButtonStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            content
                .buttonStyle(.plain)
        }
    }
}
