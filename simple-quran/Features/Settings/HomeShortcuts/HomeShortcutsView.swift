//
//  HomeShortcutsView.swift
//  simple-quran
//

import SwiftUI

/// Settings › Home Shortcuts: choose and order up to three features shown
/// on Home before the "All" tile, with a live preview of the row.
struct HomeShortcutsView: View {
    @State private var viewModel: HomeShortcutsViewModel

    init(viewModel: HomeShortcutsViewModel = HomeShortcutsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                HomeShortcutRow(
                    features: viewModel.selected,
                    onOpen: { _ in },
                    onOpenAll: {}
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .padding(.vertical, 6)
                .animation(.snappy, value: viewModel.selected)
            } header: {
                Text(NSLocalizedString("home_shortcuts_preview_title", comment: ""))
            }

            Section {
                ForEach(viewModel.selected) { feature in
                    featureLabel(feature)
                        .deleteDisabled(!viewModel.canRemove)
                }
                .onDelete(perform: viewModel.remove(atOffsets:))
                .onMove(perform: viewModel.move(fromOffsets:toOffset:))
            } header: {
                Text(NSLocalizedString("home_shortcuts_selected_title", comment: ""))
            } footer: {
                Text(
                    String(
                        format: NSLocalizedString("home_shortcuts_footer", comment: ""),
                        HomeShortcuts.limit
                    )
                )
            }

            if !viewModel.available.isEmpty {
                Section {
                    // Separate ids from "On Home" so a feature moving between
                    // sections gets a fresh row with its edit controls.
                    ForEach(viewModel.available, id: \.addRowID) { feature in
                        addRow(feature)
                    }
                } header: {
                    Text(NSLocalizedString("home_shortcuts_available_title", comment: ""))
                } footer: {
                    if !viewModel.canAdd {
                        Text(NSLocalizedString("home_shortcuts_full_footer", comment: ""))
                    }
                }
            }

            if !viewModel.isDefault {
                Section {
                    Button(NSLocalizedString("home_shortcuts_reset", comment: "")) {
                        withAnimation {
                            viewModel.resetToDefault()
                        }
                    }
                    .foregroundColor(.lightGreen)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(.sheetBackground)
        .environment(\.editMode, .constant(.active))
        .navigationTitle(NSLocalizedString("setting_home_shortcuts_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func featureLabel(_ feature: AppFeature) -> some View {
        HStack(spacing: 12) {
            FeatureIcon(systemName: feature.icon, assetName: feature.assetIcon, size: 16)
                .frame(width: 28)

            Text(feature.title)
                .font(.system(size: 16))
                .foregroundColor(.title)
        }
    }

    private func addRow(_ feature: AppFeature) -> some View {
        Button {
            withAnimation {
                viewModel.add(feature)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white, viewModel.canAdd ? Color.lightGreen : Color.gray.opacity(0.5))

                featureLabel(feature)
            }
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canAdd)
        .accessibilityLabel(
            String(
                format: NSLocalizedString("home_shortcuts_add_accessibility", comment: ""),
                feature.title
            )
        )
    }
}

private extension AppFeature {
    var addRowID: String { "add-\(rawValue)" }
}
