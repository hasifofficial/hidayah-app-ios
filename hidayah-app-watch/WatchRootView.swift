//
//  WatchRootView.swift
//  hidayah-app-watch
//

import SwiftUI

struct WatchRootView: View {
    let trackerModel: WatchTrackerModel

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
                            systemImage: "checklist"
                        )
                    }
                }

                NavigationLink {
                    WatchTasbihView()
                } label: {
                    WatchHomeRow(
                        title: String(localized: "watch_home_tasbih"),
                        subtitle: nil,
                        systemImage: "circle.grid.3x3.fill",
                        assetImage: "TasbihIconFill"
                    )
                }

                NavigationLink {
                    WatchQiblaView()
                } label: {
                    WatchHomeRow(
                        title: String(localized: "watch_home_qibla"),
                        subtitle: nil,
                        systemImage: "location.north.circle.fill"
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
    /// The same icons as the iPhone app's `AppFeature.icon` and
    /// `AppFeature.assetIcon`; an asset image wins when given.
    let systemImage: String
    var assetImage: String?

    var body: some View {
        HStack(spacing: 10) {
            icon
                .foregroundStyle(Color.lightGreen)
                .frame(width: 28)
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

    @ViewBuilder
    private var icon: some View {
        if let assetImage {
            Image(assetImage)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        } else {
            Image(systemName: systemImage)
                .font(.title3)
        }
    }
}
