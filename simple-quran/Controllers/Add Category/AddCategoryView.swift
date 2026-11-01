//
//  AddCategoryView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskManager.self) private var taskManager

    @State private var categoryName = ""
    @State private var iconName = "folder"

    private let icons = [
        "folder",
        "bookmark",
        "star",
        "heart",
        "flag",
        "calendar",
        "alarm",
        "moon.stars",
        "sunrise",
        "sun.max",
        "book",
        "checklist",
        "drop",
        "figure.walk",
        "hands.and.sparkles",
        "sparkles"
    ]

    private var trimmedName: String {
        categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TrackerFormIntro(
                        icon: "square.grid.2x2.fill",
                        title: NSLocalizedString(
                            "add_category_intro_title",
                            comment: ""
                        ),
                        subtitle: NSLocalizedString(
                            "add_category_intro_subtitle",
                            comment: ""
                        )
                    )

                    TrackerFormCard(
                        title: NSLocalizedString(
                            "add_category_category_detail_section_title",
                            comment: ""
                        )
                    ) {
                        TrackerFormTextField(
                            label: NSLocalizedString(
                                "add_category_category_detail_category_name",
                                comment: ""
                            ),
                            placeholder: NSLocalizedString(
                                "add_category_category_name_placeholder",
                                comment: ""
                            ),
                            text: $categoryName
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(
                                NSLocalizedString(
                                    "add_category_category_detail_icon",
                                    comment: ""
                                )
                            )
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textGray)

                            TrackerFormIconPicker(
                                selection: $iconName,
                                icons: icons
                            )
                        }
                    }

                    TrackerPrimaryButton(
                        title: NSLocalizedString(
                            "add_category_category_detail_add_category_button",
                            comment: ""
                        ),
                        icon: "plus",
                        isEnabled: canSave
                    ) {
                        guard canSave else { return }
                        taskManager.addCustomCategory(
                            name: trimmedName,
                            icon: iconName
                        )
                        dismiss()
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(.appBackground)
            .navigationTitle(
                NSLocalizedString("add_category_header_title", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        NSLocalizedString(
                            "add_category_cancel_button",
                            comment: ""
                        )
                    ) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Shared tracker form components

struct TrackerFormIntro: View {
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

struct TrackerFormCard<Content: View>: View {
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

struct TrackerFormTextField: View {
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

struct TrackerFormIconPicker: View {
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

struct TrackerPrimaryButton: View {
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
