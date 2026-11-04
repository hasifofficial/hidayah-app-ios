//
//  SettingView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    let viewModel: SettingsViewModel
    var onOpenTrackerSettings: (() -> Void)? = nil
    var onOpenWidgetGuide: (() -> Void)? = nil

    @State private var activeSelection: SettingsSelection?
    @State private var safariURL: URL?
    @State private var showingMail = false
    @State private var showingQuranReadingSettings = false

    @AppStorage(
        Storage.StorageKey.quranArabicFontSize.rawValue,
        store: Storage.userDefaults
    ) private var arabicFontSize = 22.0

    var body: some View {
        List {
            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_quran_section_title",
                    comment: ""
                ),
                topPadding: 16
            )

            SettingsActionRow(
                icon: "speaker.wave.2.bubble",
                title: NSLocalizedString(
                    "setting_quran_recitation_title",
                    comment: ""
                ),
                value: viewModel.selectedRecitationName
            ) {
                openSelection(.recitation)
            }

            SettingsActionRow(
                icon: "globe",
                title: NSLocalizedString(
                    "setting_quran_translation_title",
                    comment: ""
                ),
                value: viewModel.selectedTranslationName
            ) {
                openSelection(.translation)
            }

            SettingsActionRow(
                icon: "textformat.size",
                title: NSLocalizedString(
                    "setting_quran_font_size_title",
                    comment: ""
                )
            ) {
                showingQuranReadingSettings = true
            }

            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_tracker_section_title",
                    comment: ""
                )
            )

            SettingsActionRow(
                icon: "checklist.checked",
                title: NSLocalizedString(
                    "setting_tracker_title",
                    comment: ""
                )
            ) {
                onOpenTrackerSettings?()
            }

            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_widgets_section_title",
                    comment: ""
                )
            )

            SettingsActionRow(
                icon: "square.grid.2x2",
                title: NSLocalizedString(
                    "setting_widgets_action_title",
                    comment: ""
                )
            ) {
                onOpenWidgetGuide?()
            }

            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_notification_section_title",
                    comment: ""
                )
            )

            SettingsToggleRow(
                icon: "bell",
                title: NSLocalizedString(
                    "setting_notification_alkahf_title",
                    comment: ""
                ),
                isOn: Binding(
                    get: { viewModel.allowKahfReminder },
                    set: { viewModel.setKahfReminder($0) }
                )
            )

            SettingsToggleRow(
                icon: "flame",
                title: NSLocalizedString(
                    "setting_notification_tracker_cheerleader_title",
                    comment: ""
                ),
                isOn: Binding(
                    get: { viewModel.allowTrackerCheerleader },
                    set: { viewModel.setTrackerCheerleader($0) }
                )
            )

            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_about_section_title",
                    comment: ""
                )
            )

            SettingsActionRow(
                icon: "info.circle",
                title: NSLocalizedString(
                    "setting_about_us_title",
                    comment: ""
                )
            ) {
                openSafari(Constants.websiteUrl)
            }

            SettingsActionRow(
                icon: "book.pages",
                title: NSLocalizedString(
                    "setting_about_privacy_title",
                    comment: ""
                )
            ) {
                openSafari(Constants.privacyUrl)
            }

            SettingsActionRow(
                icon: "book.pages",
                title: NSLocalizedString(
                    "setting_about_term_title",
                    comment: ""
                )
            ) {
                openSafari(Constants.termConditionUrl)
            }

            SettingsSectionHeader(
                title: NSLocalizedString(
                    "setting_support_section_title",
                    comment: ""
                )
            )

            SettingsActionRow(
                icon: "text.bubble",
                title: NSLocalizedString(
                    "setting_support_feedback_title",
                    comment: ""
                )
            ) {
                sendFeedback()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.sheetBackground)
        .safeAreaInset(edge: .bottom) {
            versionLabel
        }
        .task {
            viewModel.loadEditionsIfNeeded()
        }
        .sheet(item: $activeSelection) { selection in
            SelectionView(
                title: selection.title,
                items: viewModel.items(for: selection),
                selectedValue: viewModel.selectedValue(for: selection),
                onSelect: { item in
                    viewModel.select(item, for: selection)
                }
            )
        }
        .sheet(isPresented: $showingQuranReadingSettings) {
            ReadingSettingsView(showsReadingMode: true)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingMail) {
            MailView(
                subject: feedbackSubject,
                recipients: [Constants.feedbackEmail]
            ) {
                showingMail = false
            }
            .ignoresSafeArea()
        }
        .sheet(
            isPresented: Binding(
                get: { safariURL != nil },
                set: { isPresented in
                    if !isPresented {
                        safariURL = nil
                    }
                }
            )
        ) {
            if let safariURL {
                SafariView(url: safariURL)
                    .ignoresSafeArea()
            }
        }
    }

    private var versionLabel: some View {
        Text(viewModel.versionText)
            .font(.system(size: 14))
            .foregroundColor(.textGray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.sheetBackground)
    }

    private var feedbackSubject: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

        return String(
            format: NSLocalizedString(
                "setting_support_feedback_mail_title",
                comment: ""
            ),
            appVersion,
            buildNumber
        )
    }

    private func openSelection(_ selection: SettingsSelection) {
        guard !viewModel.items(for: selection).isEmpty else { return }

        activeSelection = selection
    }

    private func openSafari(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        safariURL = url
    }

    private func sendFeedback() {
        guard MFMailComposeViewController.canSendMail() else { return }

        showingMail = true
    }
}
