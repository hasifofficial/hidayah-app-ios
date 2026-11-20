//
//  HomeShortcutsView.swift
//  hidayah-app
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
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .animation(.snappy, value: viewModel.selected)
                .settingsListRow()
            } header: {
                sectionHeader("home_shortcuts_preview_title", topPadding: 16)
            }

            Section {
                ForEach(viewModel.selected) { feature in
                    featureLabel(feature)
                        .deleteDisabled(!viewModel.canRemove)
                        .editableRow()
                }
                .onDelete(perform: viewModel.remove(atOffsets:))
                .onMove(perform: viewModel.move(fromOffsets:toOffset:))
            } header: {
                sectionHeader("home_shortcuts_selected_title")
            } footer: {
                note(
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
                            .editableRow()
                    }
                } header: {
                    sectionHeader("home_shortcuts_available_title")
                } footer: {
                    if !viewModel.canAdd {
                        note(NSLocalizedString("home_shortcuts_full_footer", comment: ""))
                    }
                }
            }

            if !viewModel.isDefault {
                Section {
                    SettingsActionRow(
                        icon: "arrow.counterclockwise",
                        title: NSLocalizedString("home_shortcuts_reset", comment: ""),
                        showsDisclosure: false
                    ) {
                        withAnimation {
                            viewModel.resetToDefault()
                        }
                    }
                } header: {
                    Color.clear.frame(height: 16).settingsListRow()
                }
            }
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .listSectionSpacing(0)
        .scrollContentBackground(.hidden)
        .background(.sheetBackground)
        .environment(\.editMode, .constant(.active))
        .navigationTitle(NSLocalizedString("setting_home_shortcuts_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The Settings section title, flush with the list like the other
    /// Settings screens.
    private func sectionHeader(_ key: String, topPadding: CGFloat = 24) -> some View {
        SettingsSectionHeader(
            title: NSLocalizedString(key, comment: ""),
            topPadding: topPadding
        )
        .background(Color.sheetBackground)
    }

    /// A small grey note under a section, as in Tracker Settings.
    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.textGray)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .settingsListRow()
    }

    private func featureLabel(_ feature: AppFeature) -> some View {
        HStack(spacing: 8) {
            FeatureIcon(systemName: feature.icon, assetName: feature.assetIcon, size: 16)
                .frame(width: 32, height: 32)

            Text(feature.title)
                .font(.system(size: 14))
                .foregroundColor(.primary)
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

private extension View {
    /// Settings-style row (no separator or card) that keeps the list's
    /// insets, so edit controls still line up.
    func editableRow() -> some View {
        listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
