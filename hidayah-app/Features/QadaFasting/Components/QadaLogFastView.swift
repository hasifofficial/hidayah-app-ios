//
//  QadaLogFastView.swift
//  hidayah-app
//

import SwiftUI

/// Logs a Qada fast, today or on an earlier day.
struct QadaLogFastView: View {
    let today: Date
    /// Logs the fast and returns an error to show, or nil on success.
    let onLog: (Date) -> String?

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var error: String?

    init(today: Date, initialDate: Date, onLog: @escaping (Date) -> String?) {
        self.today = today
        self.onLog = onLog
        _date = State(initialValue: min(initialDate, today))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppFormCard(title: NSLocalizedString("qada_log_date_section", comment: "")) {
                        DatePicker(
                            NSLocalizedString("qada_log_date_section", comment: ""),
                            selection: $date,
                            in: ...today,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.lightGreen)
                        .labelsHidden()
                        .onChange(of: date) {
                            error = nil
                        }

                        if let error {
                            Label(error, systemImage: "exclamationmark.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.orange)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    AppPrimaryButton(
                        title: NSLocalizedString("qada_log_fast", comment: ""),
                        icon: "checkmark",
                        isEnabled: true
                    ) {
                        if let message = onLog(date) {
                            error = message
                        } else {
                            dismiss()
                        }
                    }
                }
                .padding(16)
            }
            .background(.appBackground)
            .navigationTitle(NSLocalizedString("qada_log_fast_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("qada_cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}
