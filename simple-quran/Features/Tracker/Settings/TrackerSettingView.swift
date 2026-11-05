//
//  TrackerSettingView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerSettingsView: View {
    let onManageCategories: () -> Void
    let onResetDailyProgress: () -> Void
    let onResetAll: () -> Void

    @State private var activeAlert: ResetAlert?

    var body: some View {
        List {
            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_tracker_category_title",
                    comment: ""
                ),
                topPadding: 16
            )

            SettingsActionRow(
                icon: "square.grid.2x2",
                title: NSLocalizedString(
                    "setting_tracker_manage_category_title",
                    comment: ""
                )
            ) {
                onManageCategories()
            }

            Button {
                activeAlert = .daily
            } label: {
                resetRow("setting_tracker_reset_daily_progress_title")
            }
            .buttonStyle(.plain)
            .settingsListRow()

            Button {
                activeAlert = .all
            } label: {
                resetRow("setting_tracker_reset_all_title")
            }
            .buttonStyle(.plain)
            .settingsListRow()
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.sheetBackground)
        .alert(
            activeAlert?.title ?? "",
            isPresented: Binding(
                get: { activeAlert != nil },
                set: { isPresented in
                    if !isPresented {
                        activeAlert = nil
                    }
                }
            )
        ) {
            Button(
                NSLocalizedString(
                    activeAlert?.resetButtonKey ?? "setting_tracker_reset_daily_progress_alert_reset_button",
                    comment: ""
                ),
                role: .destructive
            ) {
                switch activeAlert {
                case .daily:
                    onResetDailyProgress()
                case .all:
                    onResetAll()
                case nil:
                    break
                }

                activeAlert = nil
            }

            Button(
                NSLocalizedString(
                    "setting_tracker_reset_daily_progress_alert_cancel_button",
                    comment: ""
                ),
                role: .cancel
            ) {
                activeAlert = nil
            }
        } message: {
            Text(activeAlert?.message ?? "")
        }
    }

    private func resetRow(_ key: String) -> some View {
        HStack(spacing: 12) {
            Text(NSLocalizedString(key, comment: ""))
                .foregroundColor(.red)

            Spacer()

            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private enum ResetAlert: Identifiable {
    case daily
    case all

    var id: Int {
        switch self {
        case .daily:
            return 0
        case .all:
            return 1
        }
    }

    var title: String {
        switch self {
        case .daily:
            return NSLocalizedString(
                "setting_tracker_reset_daily_progress_alert_title",
                comment: ""
            )
        case .all:
            return NSLocalizedString(
                "setting_tracker_reset_all_alert_title",
                comment: ""
            )
        }
    }

    var message: String {
        switch self {
        case .daily:
            return NSLocalizedString(
                "setting_tracker_reset_daily_progress_alert_description",
                comment: ""
            )
        case .all:
            return NSLocalizedString(
                "setting_tracker_reset_all_alert_description",
                comment: ""
            )
        }
    }

    var resetButtonKey: String {
        switch self {
        case .daily:
            return "setting_tracker_reset_daily_progress_alert_reset_button"
        case .all:
            return "setting_tracker_reset_all_alert_reset_button"
        }
    }
}
