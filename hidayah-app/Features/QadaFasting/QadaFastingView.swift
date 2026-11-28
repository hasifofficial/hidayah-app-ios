//
//  QadaFastingView.swift
//  hidayah-app
//

import SwiftUI

/// Tracks Ramadan days owed per Hijri year and the Qada fasts kept to make
/// them up. The hero's moon waxes toward full as the days are made up.
struct QadaFastingView: View {
    @Bindable var viewModel: QadaFastingViewModel
    /// Opens Settings from the navigation bar. No button when nil.
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if viewModel.isEmpty {
                    emptyState
                } else {
                    QadaMoonHeroView(
                        phase: viewModel.moonPhase,
                        remaining: viewModel.remainingCount,
                        remainingLabel: viewModel.remainingLabel,
                        summary: viewModel.heroSummary,
                        deadline: viewModel.deadline,
                        isComplete: viewModel.isAllMadeUp,
                        celebration: viewModel.celebration
                    )

                    yearsSection

                    if !viewModel.ledger.fasts.isEmpty {
                        fastsSection
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            // Room for the floating button over the last card.
            .padding(.bottom, viewModel.showsAddMenu ? 100 : 16)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: viewModel.ledger)
        }
        .background(AppGradientBackground())
        .overlay(alignment: .bottomTrailing) {
            if viewModel.showsAddMenu {
                addMenu
            }
        }
        .overlay(alignment: .top) {
            toast
        }
        .navigationTitle(NSLocalizedString("qada_header_title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if let onOpenSettings {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onOpenSettings) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .sheet(item: $viewModel.sheet) { sheet in
            sheetContent(sheet)
        }
        .confirmationDialog(
            NSLocalizedString("qada_remove_fast_title", comment: ""),
            isPresented: Binding(
                get: { viewModel.fastPendingRemoval != nil },
                set: { if !$0 { viewModel.fastPendingRemoval = nil } }
            ),
            titleVisibility: .visible,
            presenting: viewModel.fastPendingRemoval
        ) { _ in
            Button(NSLocalizedString("qada_remove_fast_action", comment: ""), role: .destructive) {
                viewModel.confirmFastRemoval()
            }
        } message: { fast in
            Text(viewModel.dateText(fast.date))
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                QadaMoonHeroBackdrop()
                Image(AppFeature.qada.illustration)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
            .frame(height: 220)

            VStack(spacing: 8) {
                Text(NSLocalizedString("qada_empty_title", comment: ""))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.title)
                    .multilineTextAlignment(.center)

                Text(NSLocalizedString("qada_empty_message", comment: ""))
                    .font(.system(size: 14))
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)

            AppPrimaryButton(
                title: NSLocalizedString("qada_add_year", comment: ""),
                icon: "plus",
                isEnabled: true
            ) {
                viewModel.sheet = .addYear
            }
            .padding(.top, 4)
        }
        .padding(.top, 8)
    }

    // MARK: - Logging

    /// The floating + button, matching the Istiqamah tracker's: log a fast
    /// or add another Ramadan.
    private var addMenu: some View {
        Menu {
            if viewModel.canLogFast {
                Button {
                    viewModel.sheet = .logFast
                } label: {
                    Label(
                        NSLocalizedString("qada_log_fast_menu", comment: ""),
                        systemImage: "calendar.badge.plus"
                    )
                }
            }

            if viewModel.canAddYear {
                Button {
                    viewModel.sheet = .addYear
                } label: {
                    Label(
                        NSLocalizedString("qada_add_year", comment: ""),
                        systemImage: "moon.stars"
                    )
                }
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(Color.lightGreen)
                .clipShape(Circle())
                .shadow(color: Color.lightGreen.opacity(0.32), radius: 12, y: 6)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .accessibilityLabel(NSLocalizedString("qada_add_menu", comment: ""))
        .padding(.trailing, 20)
        .padding(.bottom, 24)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Years

    private var yearsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(NSLocalizedString("qada_years_section", comment: ""))

            ForEach(viewModel.ledger.years) { year in
                QadaYearCard(
                    year: year,
                    title: viewModel.yearTitle(year.hijriYear),
                    detail: viewModel.yearDetail(year),
                    isNext: year.hijriYear == viewModel.nextYear,
                    nextLabel: NSLocalizedString("qada_next_badge", comment: "")
                ) {
                    viewModel.sheet = .editYear(year.hijriYear)
                }
            }
        }
    }

    // MARK: - Fasts

    private var fastsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(NSLocalizedString("qada_fasts_section", comment: ""))

            ForEach(viewModel.fastSections) { section in
                VStack(alignment: .leading, spacing: 0) {
                    Text(section.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.title)
                        .padding(.bottom, 10)

                    ForEach(Array(section.fasts.enumerated()), id: \.element.id) { index, fast in
                        fastRow(fast, isLast: index == section.fasts.count - 1)
                    }
                }
                .padding(16)
                .background(Color.backgroundGray)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }

    private func fastRow(_ fast: QadaFast, isLast: Bool) -> some View {
        let badge = viewModel.dayBadge(fast)

        return HStack(alignment: .top, spacing: 12) {
            // A calendar-page badge on a timeline line.
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(badge.weekday)
                        .font(.system(size: 9, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                        .background(Color.lightGreen)

                    Text(badge.day)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 42, height: 44)
                .background(Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.lightGreen.opacity(0.3), lineWidth: 1)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.lightGreen.opacity(0.25))
                        .frame(width: 2, height: 14)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.fastDetail(fast))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.title)

                Text(viewModel.dateText(fast.date))
                    .font(.system(size: 12))
                    .foregroundColor(.textGray)
            }
            .padding(.top, 5)

            Spacer(minLength: 0)

            Menu {
                Button(role: .destructive) {
                    viewModel.fastPendingRemoval = fast
                } label: {
                    Label(NSLocalizedString("qada_remove_fast_action", comment: ""), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textGray)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .padding(.top, 6)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Pieces

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.textGray)
            .textCase(.uppercase)
            .padding(.leading, 4)
            .padding(.top, 4)
    }

    @ViewBuilder
    private var toast: some View {
        if let message = viewModel.toast {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(QadaPalette.moonLight)
                Text(message)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(QadaPalette.nightTop.opacity(0.95), in: Capsule())
            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .task(id: viewModel.celebration) {
                try? await Task.sleep(for: .seconds(2.6))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut) {
                    viewModel.toast = nil
                }
            }
            .accessibilityAddTraits(.isStaticText)
        }
    }

    @ViewBuilder
    private func sheetContent(_ sheet: QadaFastingViewModel.Sheet) -> some View {
        switch sheet {
        case .addYear:
            QadaYearEditorView(
                mode: .add(years: viewModel.addableYears),
                yearTitle: viewModel.yearTitle,
                onSave: viewModel.saveYear,
                onRemove: { _ in }
            )
        case .editYear(let hijriYear):
            if let year = viewModel.ledger.year(hijriYear) {
                QadaYearEditorView(
                    mode: .edit(year),
                    yearTitle: viewModel.yearTitle,
                    onSave: viewModel.saveYear,
                    onRemove: viewModel.removeYear
                )
            }
        case .logFast:
            QadaLogFastView(
                today: viewModel.today,
                initialDate: viewModel.suggestedLogDate,
                onLog: viewModel.logFast
            )
        }
    }
}

/// A soft glowing disc behind the empty-state illustration.
private struct QadaMoonHeroBackdrop: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(QadaPalette.moonLight.opacity(0.25))
                .frame(width: 210, height: 210)
                .blur(radius: 30)
            Circle()
                .fill(Color.lightGreen.opacity(0.10))
                .frame(width: 180, height: 180)
        }
    }
}
