//
//  TrackerWidgetView.swift
//  app-widgetExtension
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI
import WidgetKit

struct TrackerWidgetSmallView: View {
    var entry: TrackerProvider.Entry

    private var percent: Int {
        Int(min(max(entry.progress, 0), 1) * 100)
    }

    var body: some View {
        VStack(spacing: 10) {
            widgetLogo(width: 56)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)

            progressRing(size: 96)

            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private func progressRing(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(
                    Color.lightGreen.opacity(0.16),
                    lineWidth: 8
                )

            Circle()
                .trim(from: 0, to: CGFloat(min(entry.progress, 1)))
                .stroke(
                    Color.lightGreen,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text("\(percent)%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.title)

                Text(
                    String(
                        format: NSLocalizedString(
                            "widget_tasks_count_format",
                            comment: ""
                        ),
                        entry.completedTasks,
                        entry.totalTasks
                    )
                )
                    .font(.system(size: 9))
                    .foregroundColor(.textGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(width: size, height: size)
    }
}

struct TrackerWidgetMediumView: View {
    var entry: TrackerProvider.Entry

    private var percent: Int {
        Int(min(max(entry.progress, 0), 1) * 100)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 6) {
                widgetLogo(width: 58)
                progressRing
            }
            .frame(width: 102, alignment: .center)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text(NSLocalizedString("widget_upcoming_title", comment: ""))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.title)

                    Spacer(minLength: 4)

                    Text("\(entry.completedTasks)/\(entry.totalTasks)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.textGray)
                }
                .padding(.bottom, 2)

                if entry.upcomingTasks.isEmpty {
                    completedState
                } else {
                    ForEach(entry.upcomingTasks.prefix(5), id: \.id) { task in
                        Button(
                            intent: ToggleTaskIntent(
                                id: task.id.uuidString
                            )
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "circle")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.lightGreen)

                                Text(task.name)
                                    .font(.system(size: 11))
                                    .foregroundColor(.title)
                                    .lineLimit(1)

                                Spacer(minLength: 0)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(14)
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.lightGreen.opacity(0.16),
                    lineWidth: 8
                )

            Circle()
                .trim(from: 0, to: CGFloat(min(entry.progress, 1)))
                .stroke(
                    Color.lightGreen,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text("\(percent)%")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.title)

                Text("\(entry.completedTasks)/\(entry.totalTasks)")
                    .font(.system(size: 9))
                    .foregroundColor(.textGray)
            }
        }
        .frame(width: 90, height: 90)
    }

    private var completionMessage: String {
        let messages = (1...5).map { index in
            NSLocalizedString("widget_completion_\(index)", comment: "")
        }

        let seed = Int(entry.date.timeIntervalSince1970 / 900)
        return messages[abs(seed) % messages.count]
    }

    private var completedState: some View {
        let hasTasks = entry.totalTasks > 0
        let allComplete = hasTasks
            && entry.completedTasks >= entry.totalTasks
        let remaining = max(entry.totalTasks - entry.completedTasks, 0)

        return HStack(spacing: 6) {
            Image(
                systemName: allComplete
                    ? "checkmark.seal.fill"
                    : (hasTasks ? "circle.dashed" : "plus.circle.fill")
            )
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.lightGreen)

            VStack(alignment: .leading, spacing: 1) {
                Text(
                    allComplete
                        ? NSLocalizedString("widget_complete_title", comment: "")
                        : NSLocalizedString(hasTasks ? "widget_no_upcoming_title" : "widget_no_tasks_title", comment: "")
                )
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.title)

                Text(
                    allComplete
                        ? completionMessage
                        : (hasTasks
                            ? String(format: NSLocalizedString("widget_remaining_format", comment: ""), remaining)
                            : NSLocalizedString("widget_add_tasks_hint", comment: ""))
                )
                .font(.system(size: 9))
                .foregroundColor(.textGray)
                .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

struct TrackerWidgetEntryView: View {
    var entry: TrackerProvider.Entry

    @Environment(\.widgetFamily) private var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        Group {
            if family == .systemMedium {
                TrackerWidgetMediumView(entry: entry)
            } else {
                TrackerWidgetSmallView(entry: entry)
            }
        }
        .widgetURL(URL(string: "hidayahapp://inAppDeeplink/tracker"))
        .containerBackground(for: .widget) {
            TrackerWidgetBackground()
        }
    }
}

struct TrackerWidgetBackground: View {
    @Environment(\.widgetFamily) private var family

    private var tintOpacity: Double {
        family == .systemSmall ? 0.26 : 0.18
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)

            LinearGradient(
                colors: [
                    Color.lightGreen.opacity(tintOpacity),
                    Color.lightGreen.opacity(tintOpacity * 0.35),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private func widgetLogo(width: CGFloat) -> some View {
    Image("hidayah_logo")
        .resizable()
        .scaledToFit()
        .frame(width: width, height: width * 0.5)
}
