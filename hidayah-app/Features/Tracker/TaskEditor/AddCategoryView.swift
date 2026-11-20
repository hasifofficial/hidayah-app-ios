//
//  AddCategoryView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskManager.self) private var taskManager

    @State private var viewModel = AddCategoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppFormHeader(
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

                    AppFormCard(
                        title: NSLocalizedString(
                            "add_category_category_detail_section_title",
                            comment: ""
                        )
                    ) {
                        AppTextField(
                            label: NSLocalizedString(
                                "add_category_category_detail_category_name",
                                comment: ""
                            ),
                            placeholder: NSLocalizedString(
                                "add_category_category_name_placeholder",
                                comment: ""
                            ),
                            text: $viewModel.categoryName,
                            focusesOnAppear: true
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

                            AppIconPicker(
                                selection: $viewModel.iconName,
                                icons: viewModel.icons
                            )
                        }
                    }

                    AppPrimaryButton(
                        title: NSLocalizedString(
                            "add_category_category_detail_add_category_button",
                            comment: ""
                        ),
                        icon: "plus",
                        isEnabled: viewModel.canSave
                    ) {
                        if viewModel.save(using: taskManager) {
                            dismiss()
                        }
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
