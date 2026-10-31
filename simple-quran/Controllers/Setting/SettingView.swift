//
//  SettingView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import SwiftUI
import UIKit
import SafariServices
import MessageUI

struct SettingsView: View {
    let viewModel: SettingsViewModel
    var onOpenTrackerSettings: (() -> Void)? = nil

    @State private var activeSelection: SettingsSelection?
    @State private var safariURL: URL?
    @State private var showingMail = false

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
            .background(.appBackground)
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

struct SettingsSectionHeader: View {
    let title: String
    var topPadding: CGFloat = 24

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.primary)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, topPadding)
            .padding(.bottom, 8)
            .settingsListRow()
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    var value: String?
    var showsDisclosure: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 32, height: 32)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)

                Spacer(minLength: 8)

                if let value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.textGray)
                        .lineLimit(1)
                }

                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textGray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .settingsListRow()
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 32, height: 32)
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.lightGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .settingsListRow()
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}

struct MailView: UIViewControllerRepresentable {
    let subject: String
    let recipients: [String]
    let onFinish: () -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        return controller
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let onFinish: () -> Void

        init(onFinish: @escaping () -> Void) {
            self.onFinish = onFinish
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true)
            onFinish()
        }
    }
}

private extension View {
    func settingsListRow() -> some View {
        self
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
