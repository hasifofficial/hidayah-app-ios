//
//  appWidget.swift
//  app-widget
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    @AppStorage(
        Storage.StorageKey.widgetContext.rawValue,
        store: Storage.userDefaults
    ) var widgetContext = Data()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            progress: 0.65,
            completedTasks: 15,
            totalTasks: 23,
            upcomingTasks: [
                .init(
                    name: "Tahajjud prayer with do'a",
                    category: .default(.tahajjud)
                ),
                .init(
                    name: "Read Quran",
                    category: .default(.recitation)
                ),
                .init(
                    name: "Morning adhkar",
                    category: .default(.morning)
                )
            ],
            currentStreak: 7,
            level: 4,
            points: 620
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> ()
    ) {
        let entry = SimpleEntry(
            date: Date(),
            progress: 0.65,
            completedTasks: 15,
            totalTasks: 23,
            upcomingTasks: [
                .init(
                    name: "Tahajjud prayer with do'a",
                    category: .default(.tahajjud)
                ),
                .init(
                    name: "Read Quran",
                    category: .default(.recitation)
                ),
                .init(
                    name: "Morning adhkar",
                    category: .default(.morning)
                )
            ],
            currentStreak: 7,
            level: 4,
            points: 620
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let widgetContext: WidgetContext? = Storage.loadObject(
            key: .widgetContext
        )
        let entry = SimpleEntry(
            date: Date(),
            progress: widgetContext?.progress ?? 0,
            completedTasks: widgetContext?.completedTasks ?? 0,
            totalTasks: widgetContext?.totalTasks ?? 1,
            upcomingTasks: widgetContext?.upcomingTasks ?? [],
            currentStreak: widgetContext?.currentStreak ?? 0,
            level: widgetContext?.level ?? 1,
            points: widgetContext?.points ?? 0
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(60 * 15))
        )
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let completedTasks: Int
    let totalTasks: Int
    let upcomingTasks: [TaskDetails]
    var currentStreak: Int = 0
    var level: Int = 1
    var points: Int = 0
}

struct IstiqamahWidgetSmallView: View {
    var entry: Provider.Entry

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

                Text("\(entry.completedTasks)/\(entry.totalTasks) tasks")
                    .font(.system(size: 9))
                    .foregroundColor(.textGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(width: size, height: size)
    }
}

struct IstiqamahWidgetMediumView: View {
    var entry: Provider.Entry

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
                    Text("Upcoming")
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
                        ? "All tasks complete"
                        : (hasTasks ? "No upcoming tasks" : "No tasks yet")
                )
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.title)

                Text(
                    allComplete
                        ? "Alhamdulillah"
                        : (hasTasks
                            ? "\(remaining) remaining"
                            : "Add tasks in the app")
                )
                .font(.system(size: 9))
                .foregroundColor(.textGray)
            }
        }
        .padding(.vertical, 2)
    }
}

struct IstiqamahWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) private var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        Group {
            if family == .systemMedium {
                IstiqamahWidgetMediumView(entry: entry)
            } else {
                IstiqamahWidgetSmallView(entry: entry)
            }
        }
        .widgetURL(URL(string: "hidayahapp://inAppDeeplink/tracker"))
        .containerBackground(for: .widget) {
            IstiqamahWidgetBackground()
        }
    }
}

struct IstiqamahWidgetBackground: View {
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



struct appWidget: Widget {
    let kind: String = "IstiqamahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            IstiqamahWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Istiqamah Tracker")
        .description("View your daily progress and upcoming tasks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    appWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        progress: 0.65,
        completedTasks: 15,
        totalTasks: 23,
        upcomingTasks: [
            .init(
                name: "Tahajjud prayer with do'a",
                category: .default(.tahajjud)
            ),
            .init(
                name: "Read Quran",
                category: .default(.recitation)
            ),
            .init(
                name: "Morning adhkar",
                category: .default(.morning)
            )
        ],
        currentStreak: 7,
        level: 4,
        points: 620
    )
}
