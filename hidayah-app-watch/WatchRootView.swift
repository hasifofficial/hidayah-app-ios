//
//  WatchRootView.swift
//  hidayah-app-watch
//

import SwiftUI

struct WatchRootView: View {
    let trackerModel: WatchTrackerModel
    let rakaatModel: WatchRakaatModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                NavigationLink {
                    WatchTrackerView(model: trackerModel)
                } label: {
                    TimelineView(.everyMinute) { context in
                        WatchHomeRow(
                            title: String(localized: "watch_home_tracker"),
                            subtitle: trackerSubtitle(now: context.date),
                            illustration: "IllustrationTracker"
                        )
                    }
                }

                NavigationLink {
                    WatchTasbihView()
                } label: {
                    WatchHomeRow(
                        title: String(localized: "watch_home_tasbih"),
                        subtitle: nil,
                        illustration: "IllustrationTasbih"
                    )
                }

                NavigationLink {
                    WatchRakaatView(model: rakaatModel)
                } label: {
                    WatchHomeRow(
                        title: String(localized: "watch_home_rakaat"),
                        subtitle: rakaatSubtitle,
                        illustration: "IllustrationRakaat"
                    )
                }

                NavigationLink {
                    WatchQiblaView()
                } label: {
                    WatchHomeRow(
                        title: String(localized: "watch_home_qibla"),
                        subtitle: nil,
                        illustration: "IllustrationQibla"
                    )
                }
                } header: {
                    // The app's logo in place of a text title, as on the
                    // iPhone's Home screen.
                    Image("hidayah_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Hidayah")
                        .accessibilityAddTraits(.isHeader)
                }
            }
        }
        .tint(.lightGreen)
    }

    /// Shows the iPhone's live count, so you can glance at it from Home.
    private var rakaatSubtitle: String? {
        guard rakaatModel.isMirroring else { return nil }
        return String(
            format: String(localized: "watch_home_rakaat_live_format"),
            rakaatModel.completedRakaat,
            rakaatModel.rakaatCount
        )
    }

    private func trackerSubtitle(now: Date) -> String {
        guard trackerModel.state.snapshot != nil else {
            return String(localized: "watch_home_tracker_not_synced")
        }
        let progress = trackerModel.state.progress(now: now)
        return String(
            format: String(localized: "watch_home_tracker_progress_format"),
            progress.completed,
            progress.total
        )
    }
}

private struct WatchHomeRow: View {
    let title: String
    let subtitle: String?
    /// The same illustration as the iPhone app's `AppFeature.illustration`.
    let illustration: String

    var body: some View {
        HStack(spacing: 10) {
            Image(illustration)
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
