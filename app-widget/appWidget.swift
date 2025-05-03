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
    
    func placeholder(
        in context: Context
    ) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            progress: 0.65,
            completedTasks: 15,
            totalTasks: 23,
            upcomingTasks: [
                .init(
                    name: "Taubah prayer with do'a",
                    category: .default(.tahajjud)
                ),
                .init(
                    name: "Hajat prayer with do'a",
                    category: .default(.tahajjud)
                ),
                .init(
                    name: "Tahajjud prayer with do'a",
                    category: .default(.tahajjud)
                ),
            ]
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
                    name: "Taubah prayer with do'a",
                    category: .default(.tahajjud)
                ),
                .init(
                    name: "Hajat prayer with do'a",
                    category: .default(.tahajjud)
                ),
                .init(
                    name: "Tahajjud prayer with do'a",
                    category: .default(.tahajjud)
                ),
            ]
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let widgetContext: WidgetContext? = Storage.loadObject(key: .widgetContext)
        let entry = SimpleEntry(
            date: Date(),
            progress: widgetContext?.progress ?? 0,
            completedTasks: widgetContext?.completedTasks ?? 0,
            totalTasks: widgetContext?.totalTasks ?? 1,
            upcomingTasks: widgetContext?.upcomingTasks ?? []
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
}

struct IstiqamahWidgetMediumView: View {
    var entry: Provider.Entry
    
    private func randomCongratulation() -> String {
        let words = [
            "Alhamdulillah, Congratulations! you have done a great job! 🎉",
            "Alhamdulillah, Fantastic work! you've nailed it perfectly! 🎉",
            "Alhamdulillah, Outstanding job! your dedication really paid off! 🎉",
            "Alhamdulillah, You crushed it! 100% completion is no small feat! 🎉",
            "Alhamdulillah, Amazing effort! you've set a high standard! 🎉",
            "Alhamdulillah, Well done! your hard work and precision are impressive! 🎉",
            "Alhamdulillah, Perfect execution! you've truly gone above and beyond! 🎉",
        ]

        return words.randomElement() ?? "Alhamdulillah, Congratulations! you have done a great job! 🎉"
    }

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                VStack {
                    Image("hidayah_logo")
                        .resizable()
                        .frame(width: 70, height: 35)

                    Spacer()
                }
            }

            HStack(alignment: .center) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.3)
                        .foregroundColor(Color(uiColor: .lightGreen))
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(entry.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color(uiColor: .lightGreen))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: entry.progress)
                    
                    VStack {
                        Text("\(Int(entry.progress * 100))%")
                            .font(.system(size: 18))
                            .bold()
                        Text("\(entry.completedTasks)/\(entry.totalTasks) tasks")
                            .font(.system(size: 10))
                            .foregroundColor(Color(uiColor: .textGray))
                    }
                }
                .frame(width: 100, height: 100)
                
                VStack(alignment: .trailing) {
                    if !entry.upcomingTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upcoming:")
                                .font(.system(size: 14))
                                .bold()
                                .foregroundColor(Color(uiColor: .title))
                            
                            ForEach(entry.upcomingTasks.prefix(3), id: \.id.self) { task in
                                Button(
                                    intent: ToggleTaskIntent(
                                        id: task.id.uuidString
                                    )
                                ) {
                                    HStack {
                                        Image(systemName: "circle")
                                            .font(.system(size: 12))
                                        Text(task.name)
                                            .font(.system(size: 12))
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        VStack {
                            Text(randomCongratulation())
                                .font(.system(size: 12))
                                .bold()
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                Spacer()
            }
        }
    }
}

struct IstiqamahWidgetSmallView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Image("hidayah_logo")
                .resizable()
                .frame(width: 60, height: 30)
                .padding(.top, -8)

            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color(uiColor: .lightGreen))
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(entry.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(uiColor: .lightGreen))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: entry.progress)
                
                VStack {
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 18))
                        .bold()
                    Text("\(entry.completedTasks)/\(entry.totalTasks) tasks")
                        .font(.system(size: 10))
                        .foregroundColor(Color(uiColor: .textGray))
                }
            }
            .frame(width: 100, height: 100)
        }
    }
}

struct IstiqamahWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family: WidgetFamily
    @ViewBuilder
    var body: some View {
        if family == .systemMedium {
            IstiqamahWidgetMediumView(
                entry: entry
            )
            .widgetURL(URL(string: "hidayahapp://inAppDeeplink/tracker"))
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            IstiqamahWidgetSmallView(
                entry: entry
            )
            .widgetURL(URL(string: "hidayahapp://inAppDeeplink/tracker"))
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}

struct appWidget: Widget {
    let kind: String = "IstiqamahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            IstiqamahWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName("Istiqamah Tracker")
        .description("View your daily progress and upcoming tasks.")
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium
            ]
        )
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
                name: "Taubah prayer with do'a",
                category: .default(.tahajjud)
            ),
            .init(
                name: "Hajat prayer with do'a",
                category: .default(.tahajjud)
            ),
            .init(
                name: "Tahajjud prayer with do'a",
                category: .default(.tahajjud)
            ),
        ]
    )
}
