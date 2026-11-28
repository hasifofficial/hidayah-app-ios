//
//  QadaYearEditorView.swift
//  hidayah-app
//

import SwiftUI

/// Adds a Ramadan with the days owed, or changes or removes one.
struct QadaYearEditorView: View {
    enum Mode {
        /// The Hijri years that can be added, newest first.
        case add(years: [Int])
        case edit(QadaYear)
    }

    let mode: Mode
    let yearTitle: (Int) -> String
    let onSave: (_ hijriYear: Int, _ owedDays: Int) -> Void
    let onRemove: (_ hijriYear: Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hijriYear: Int
    @State private var owedDays: Int
    @State private var confirmsRemoval = false

    init(
        mode: Mode,
        yearTitle: @escaping (Int) -> String,
        onSave: @escaping (_ hijriYear: Int, _ owedDays: Int) -> Void,
        onRemove: @escaping (_ hijriYear: Int) -> Void
    ) {
        self.mode = mode
        self.yearTitle = yearTitle
        self.onSave = onSave
        self.onRemove = onRemove

        switch mode {
        case .add(let years):
            _hijriYear = State(initialValue: years.first ?? 0)
            _owedDays = State(initialValue: 1)
        case .edit(let year):
            _hijriYear = State(initialValue: year.hijriYear)
            _owedDays = State(initialValue: year.owedDays)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    /// Matches the Ramadan's card: a full moon once it's complete.
    private var headerIllustration: String {
        if case .edit(let year) = mode, year.isComplete {
            return Illustration.qadaMoonFull
        }
        return Illustration.qadaMoon
    }

    /// Days already made up can't be owed away.
    private var minimumDays: Int {
        if case .edit(let year) = mode {
            return max(year.madeUpDays, 1)
        }
        return 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppFormHeader(
                        icon: "moon.stars.fill",
                        title: NSLocalizedString(
                            isEditing ? "qada_edit_year_intro_title" : "qada_add_year_intro_title",
                            comment: ""
                        ),
                        subtitle: NSLocalizedString("qada_year_intro_subtitle", comment: ""),
                        illustration: headerIllustration
                    )

                    AppFormCard(title: NSLocalizedString("qada_year_section", comment: "")) {
                        yearField
                        daysField
                    }

                    AppPrimaryButton(
                        title: NSLocalizedString("qada_save_year", comment: ""),
                        icon: "checkmark",
                        isEnabled: hijriYear > 0
                    ) {
                        onSave(hijriYear, owedDays)
                        dismiss()
                    }

                    if isEditing {
                        AppDestructiveButton(
                            title: NSLocalizedString("qada_remove_year", comment: ""),
                            icon: "trash"
                        ) {
                            confirmsRemoval = true
                        }
                    }
                }
                .padding(16)
            }
            .background(.appBackground)
            .navigationTitle(
                NSLocalizedString(isEditing ? "qada_edit_year" : "qada_add_year", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("qada_cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .confirmationDialog(
                String(
                    format: NSLocalizedString("qada_remove_year_title", comment: ""),
                    yearTitle(hijriYear)
                ),
                isPresented: $confirmsRemoval,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("qada_remove_year", comment: ""), role: .destructive) {
                    onRemove(hijriYear)
                    dismiss()
                }
            } message: {
                Text(NSLocalizedString("qada_remove_year_message", comment: ""))
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var yearField: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(NSLocalizedString("qada_year_label", comment: ""))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textGray)

            switch mode {
            case .add(let years):
                Menu {
                    Picker(selection: $hijriYear) {
                        ForEach(years, id: \.self) { year in
                            Text(yearTitle(year)).tag(year)
                        }
                    } label: {
                        EmptyView()
                    }
                } label: {
                    fieldBox {
                        Text(yearTitle(hijriYear))
                            .foregroundColor(.title)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textGray)
                    }
                }
            case .edit:
                fieldBox {
                    Text(yearTitle(hijriYear))
                        .foregroundColor(.title)
                    Spacer()
                }
            }
        }
    }

    private var daysField: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(NSLocalizedString("qada_days_owed_label", comment: ""))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textGray)

            fieldBox {
                Text(QadaFastingViewModel.daysText(owedDays))
                    .foregroundColor(.title)
                    .contentTransition(.numericText())
                Spacer()
                Stepper(
                    "",
                    value: $owedDays.animation(),
                    in: minimumDays...QadaYear.maxOwedDays
                )
                .labelsHidden()
            }

            if case .edit(let year) = mode, year.madeUpDays > 0 {
                Text(
                    String(
                        format: NSLocalizedString("qada_already_made_up", comment: ""),
                        year.madeUpDays
                    )
                )
                .font(.system(size: 12))
                .foregroundColor(.textGray)
            }
        }
    }

    private func fieldBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            content()
        }
        .font(.system(size: 15))
        .padding(.horizontal, 12)
        .frame(minHeight: 46)
        .background(Color.appBackground.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
