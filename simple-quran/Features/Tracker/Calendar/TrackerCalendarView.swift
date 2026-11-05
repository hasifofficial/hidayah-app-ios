//
//  TrackerCalendarView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerCalendarView: View {
    let onSelectDay: (String) -> Void

    @State private var viewModel: TrackerCalendarViewModel
    @State private var showingMonthPicker = false
    @State private var pickerMonth = 1
    @State private var pickerYear = 2026

    init(
        taskManager: TaskManager,
        onSelectDay: @escaping (String) -> Void
    ) {
        self.onSelectDay = onSelectDay
        _viewModel = State(
            initialValue: TrackerCalendarViewModel(
                taskManager: taskManager
            )
        )
    }

    private var displayedMonth: Date {
        viewModel.displayedMonth
    }

    private var calendar: Calendar {
        viewModel.calendar
    }

    private var monthTitle: String {
        viewModel.monthTitle
    }

    private var activeDayCount: Int {
        viewModel.activeDayCount
    }

    private var perfectDayCount: Int {
        viewModel.perfectDayCount
    }

    private var completedTaskCount: Int {
        viewModel.completedTaskCount
    }

    private var weekdaySymbols: [String] {
        viewModel.weekdaySymbols
    }

    private var monthDays: [TrackerCalendarDay?] {
        viewModel.monthDays
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                monthCard
                    .loadAnimation(offset: 14)

                weekdayHeader
                    .loadAnimation(delay: 0.05)

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 6),
                        count: 7
                    ),
                    spacing: 6
                ) {
                    ForEach(Array(monthDays.enumerated()), id: \.offset) { index, day in
                        if let day {
                            dayButton(day)
                                .loadAnimation(
                                    delay: min(Double(index) * 0.008, 0.25),
                                    offset: 8
                                )
                        } else {
                            Color.clear
                                .frame(height: 52)
                        }
                    }
                }

                legend
                    .loadAnimation(delay: 0.15)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(.appBackground)
        .navigationTitle(
            NSLocalizedString("tracker_calendar_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMonthPicker) {
            monthYearPicker
                .presentationDetents([.height(330)])
                .presentationDragIndicator(.visible)
        }
    }

    private var monthCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Button {
                    moveMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.title)
                        .frame(width: 34, height: 34)
                        .background(Color.appBackground.opacity(0.55))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Button {
                        openMonthPicker()
                    } label: {
                        HStack(spacing: 5) {
                            Text(monthTitle)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.title)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.textGray)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(
                        NSLocalizedString(
                            "tracker_calendar_choose_month_title",
                            comment: ""
                        )
                    )

                    Text(
                        String(
                            format: NSLocalizedString(
                                "tracker_calendar_active_summary",
                                comment: ""
                            ),
                            activeDayCount
                        )
                    )
                    .font(.system(size: 12))
                    .foregroundColor(.textGray)
                }

                Spacer(minLength: 8)

                Button {
                    viewModel.displayedMonth = startOfMonth(Date())
                } label: {
                    Text(NSLocalizedString("tracker_calendar_today", comment: ""))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.lightGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.lightGreen.opacity(0.12))
                        .clipShape(Capsule())
                }

                Button {
                    moveMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.title)
                        .frame(width: 34, height: 34)
                        .background(Color.appBackground.opacity(0.55))
                        .clipShape(Circle())
                }
            }

            HStack(spacing: 8) {
                metricTile(
                    value: "\(activeDayCount)",
                    label: "tracker_calendar_active_days",
                    icon: "checkmark.circle.fill",
                    color: .lightGreen
                )
                metricTile(
                    value: "\(perfectDayCount)",
                    label: "tracker_calendar_perfect_days",
                    icon: "star.circle.fill",
                    color: .orange
                )
                metricTile(
                    value: "\(completedTaskCount)",
                    label: "tracker_calendar_tasks_completed",
                    icon: "bolt.fill",
                    color: .yellow
                )
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightGreen.opacity(0.14),
                            Color.backgroundGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
    }

    private func metricTile(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.title)

            Text(NSLocalizedString(label, comment: ""))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textGray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.appBackground.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textGray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }

    private func dayButton(_ day: TrackerCalendarDay) -> some View {
        let isFuture = day.date > calendar.startOfDay(for: Date())
        let isBeforeStart = viewModel.startDayKey.map {
            day.dayKey < $0
        } ?? true
        let isToday = day.dayKey == TrackerDayKey.today()
        let progress = day.record?.progress ?? 0
        let isComplete = progress >= 1

        return Button {
            guard !isFuture else { return }
            onSelectDay(day.dayKey)
        } label: {
            VStack(spacing: 5) {
                Text("\(day.dayNumber)")
                    .font(
                        .system(
                            size: 14,
                            weight: isToday ? .bold : .medium
                        )
                    )
                    .foregroundColor(
                        isComplete ? .lightGreen : .title
                    )

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.textGray.opacity(0.12))
                        .frame(width: 24, height: 3)

                    Capsule()
                        .fill(Color.lightGreen)
                        .frame(
                            width: 24 * progress,
                            height: 3
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(dayBackground(progress: progress, isBeforeStart: isBeforeStart))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isToday
                            ? Color.lightGreen
                            : Color.clear,
                        lineWidth: 1.5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .opacity(isFuture ? 0.3 : 1)
        .accessibilityLabel(
            String(
                format: NSLocalizedString(
                    "tracker_calendar_day_accessibility",
                    comment: ""
                ),
                day.dayNumber,
                monthTitle,
                Int(progress * 100)
            )
        )
    }

    private func dayBackground(
        progress: Double,
        isBeforeStart: Bool
    ) -> Color {
        if isBeforeStart {
            return Color.gray.opacity(0.04)
        }
        if progress >= 1 {
            return Color.lightGreen.opacity(0.14)
        }
        if progress > 0 {
            return Color.lightGreen.opacity(0.08)
        }
        return Color.gray.opacity(0.06)
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(color: .lightGreen, title: "tracker_calendar_complete")
            legendItem(
                color: Color.lightGreen.opacity(0.18),
                title: "tracker_calendar_partial"
            )
            legendItem(
                color: Color.gray.opacity(0.12),
                title: "tracker_calendar_missed"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(NSLocalizedString(title, comment: ""))
                .font(.system(size: 11))
                .foregroundColor(.textGray)
        }
    }

    private var monthYearPicker: some View {
        NavigationStack {
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Picker(
                        NSLocalizedString(
                            "tracker_calendar_month_title",
                            comment: ""
                        ),
                        selection: $pickerMonth
                    ) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthNames[month - 1])
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker(
                        NSLocalizedString(
                            "tracker_calendar_year_title",
                            comment: ""
                        ),
                        selection: $pickerYear
                    ) {
                        ForEach(yearRange, id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .labelsHidden()
                .padding(.horizontal, 8)
            }
            .navigationTitle(
                NSLocalizedString(
                    "tracker_calendar_choose_month_title",
                    comment: ""
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        NSLocalizedString(
                            "tracker_calendar_cancel",
                            comment: ""
                        )
                    ) {
                        showingMonthPicker = false
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        NSLocalizedString(
                            "tracker_calendar_go",
                            comment: ""
                        )
                    ) {
                        goToSelectedMonth()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.lightGreen)
                }
            }
        }
    }

    private var monthNames: [String] {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.calendar = calendar
        return formatter.monthSymbols
    }

    private var yearRange: ClosedRange<Int> {
        let currentYear = calendar.component(.year, from: Date())
        return (currentYear - 20)...(currentYear + 10)
    }

    private func openMonthPicker() {
        pickerMonth = calendar.component(.month, from: displayedMonth)
        pickerYear = calendar.component(.year, from: displayedMonth)
        showingMonthPicker = true
    }

    private func goToSelectedMonth() {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = pickerYear
        components.month = pickerMonth
        components.day = 1

        if let date = calendar.date(from: components) {
            viewModel.displayedMonth = startOfMonth(date)
        }
        showingMonthPicker = false
    }

    private func moveMonth(by value: Int) {
        viewModel.moveMonth(by: value)
    }

    private func startOfMonth(_ date: Date) -> Date {
        viewModel.startOfMonth(date)
    }

}
