//
//  WidgetGuidePreviewView.swift
//  simple-quran
//

import SwiftUI

struct WidgetGuidePreviewView: View {
    let kind: WidgetGuideKind
    let progress: Double
    let completedCount: Int
    let totalCount: Int
    let upcomingTasks: [TaskDetails]
    let quickSurahs: [WidgetGuideSurah]

    var body: some View {
        VStack(spacing: 10) {
            Text(NSLocalizedString("widget_guide_live_preview", comment: ""))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textGray)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(Color.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    }

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.13, green: 0.24, blue: 0.28),
                                    Color(red: 0.18, green: 0.38, blue: 0.33),
                                    Color(red: 0.08, green: 0.17, blue: 0.19)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 12) {
                        statusBar
                        Spacer(minLength: 0)

                        if kind == .tracker {
                            trackerWidgetPreview
                        } else {
                            quickSurahWidgetPreview
                        }

                        Text("Hidayah")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.78))

                        Spacer(minLength: 0)
                        homeScreenIcons
                    }
                    .padding(16)

                    Capsule()
                        .fill(Color.black)
                        .frame(width: 92, height: 26)
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(Color(red: 0.05, green: 0.06, blue: 0.07))
                                .frame(width: 7, height: 7)
                                .padding(.trailing, 7)
                        }
                        .padding(.top, 8)
                }
                .padding(7)
            }
            .frame(height: 356)
        }
    }

    private var statusBar: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "cellularbars")
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
    }

    private var trackerWidgetPreview: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 7) {
                Image("hidayah_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 27)

                ZStack {
                    Circle()
                        .stroke(
                            Color.lightGreen.opacity(0.18),
                            lineWidth: 6
                        )

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.lightGreen,
                            style: StrokeStyle(
                                lineWidth: 6,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.title)
                }
                .frame(width: 62, height: 62)
            }
            .frame(width: 72)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 4) {
                    Text(NSLocalizedString("widget_upcoming_title", comment: ""))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.title)

                    Spacer(minLength: 4)

                    Text("\(completedCount)/\(totalCount)")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.textGray)
                }

                if upcomingTasks.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.dashed")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.lightGreen)

                        Text(NSLocalizedString("widget_guide_no_upcoming", comment: ""))
                            .font(.system(size: 9))
                            .foregroundColor(.textGray)
                    }
                    .padding(.top, 2)
                } else {
                    ForEach(upcomingTasks, id: \.id) { task in
                        HStack(spacing: 6) {
                            Image(systemName: "circle")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.lightGreen)

                            Text(task.name)
                                .font(.system(size: 9))
                                .foregroundColor(.title)
                                .lineLimit(1)

                            Spacer(minLength: 0)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 304, height: 140, alignment: .topLeading)
        .background(widgetSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.28), radius: 12, y: 6)
    }

    private var quickSurahWidgetPreview: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image("hidayah_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 26)

                Text(NSLocalizedString("widget_quick_access_title", comment: ""))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.title)

                Spacer(minLength: 4)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.lightGreen)
            }

            HStack(spacing: 6) {
                ForEach(quickSurahs) { surah in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(surah.number)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.lightGreen)

                        Spacer(minLength: 0)

                        Text(surah.arabic)
                            .font(.kitabRegular(size: 18))
                            .foregroundColor(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Text(surah.name)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.textGray)
                            .lineLimit(1)
                    }
                    .padding(7)
                    .frame(maxWidth: .infinity)
                    .frame(height: 78)
                    .background(Color.lightGreen.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
            }
        }
        .padding(12)
        .frame(width: 304, height: 140, alignment: .topLeading)
        .background(widgetSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.28), radius: 12, y: 6)
    }

    private var widgetSurface: some View {
        ZStack {
            Color(.systemBackground)

            LinearGradient(
                colors: [
                    Color.lightGreen.opacity(0.18),
                    Color.lightGreen.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var homeScreenIcons: some View {
        HStack(spacing: 0) {
            homeScreenIcon(
                "message.fill",
                titleKey: "widget_guide_app_messages",
                background: Color(red: 0.20, green: 0.78, blue: 0.35),
                foreground: .white
            )
            Spacer(minLength: 0)
            homeScreenIcon(
                "safari.fill",
                titleKey: "widget_guide_app_safari",
                background: Color(red: 0.12, green: 0.48, blue: 0.92),
                foreground: .white
            )
            Spacer(minLength: 0)
            homeScreenIcon(
                "camera.fill",
                titleKey: "widget_guide_app_camera",
                background: Color(red: 0.62, green: 0.62, blue: 0.64),
                foreground: Color(red: 0.20, green: 0.20, blue: 0.22)
            )
            Spacer(minLength: 0)
            homeScreenIcon(
                "music.note",
                titleKey: "widget_guide_app_music",
                background: .white,
                foreground: .black
            )
        }
        .frame(width: 304)
        .padding(.bottom, 2)
    }

    private func homeScreenIcon(
        _ icon: String,
        titleKey: String,
        background: Color,
        foreground: Color
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(foreground)
                .frame(width: 44, height: 44)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            Text(NSLocalizedString(titleKey, comment: ""))
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.82))
                .lineLimit(1)
        }
    }
}
