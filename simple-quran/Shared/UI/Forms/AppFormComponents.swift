//
//  AppFormComponents.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

struct AppFormHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.lightGreen.opacity(0.14))

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.lightGreen)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.title)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.textGray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightGreen.opacity(0.12),
                            Color.backgroundGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.14), lineWidth: 1)
        }
    }
}

struct AppFormCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.textGray)
                .textCase(.uppercase)

            content
        }
        .padding(16)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
        }
    }
}

struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textGray)

            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(.title)
                .textInputAutocapitalization(.sentences)
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(Color.appBackground.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct AppIconPicker: View {
    @Binding var selection: String
    let icons: [String]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 5
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(icons, id: \.self) { icon in
                Button {
                    selection = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(
                            selection == icon ? .white : .lightGreen
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            selection == icon
                                ? Color.lightGreen
                                : Color.appBackground.opacity(0.65)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 11,
                                style: .continuous
                            )
                            .stroke(
                                selection == icon
                                    ? Color.lightGreen
                                    : Color.lightGreen.opacity(0.12),
                                lineWidth: 1
                            )
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(icon)
            }
        }
    }
}

struct AppPrimaryButton: View {
    let title: String
    let icon: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isEnabled
                    ? Color.lightGreen
                    : Color.lightGreen.opacity(0.35)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

