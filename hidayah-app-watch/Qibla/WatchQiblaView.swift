//
//  WatchQiblaView.swift
//  hidayah-app-watch
//

import SwiftUI

/// A compact Qibla compass: an arrow that points to the Kaaba and the screen
/// turns green when you face it. Logic lives in the shared `QiblaViewModel`.
struct WatchQiblaView: View {
    @State private var viewModel = QiblaViewModel(sensor: CoreLocationQiblaSensor())

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                (viewModel.isAligned ? Color.lightGreen : Color.black)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isAligned)
            )
            .navigationTitle(String(localized: "qibla_header_title"))
            .onAppear { viewModel.onAppear() }
            .onDisappear { viewModel.onDisappear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.status {
        case .needsPermission:
            WatchQiblaMessage(
                systemImage: "location",
                title: String(localized: "qibla_permission_title"),
                message: String(localized: "watch_qibla_permission_message"),
                actionTitle: String(localized: "qibla_permission_action"),
                action: viewModel.requestPermission
            )
        case .denied:
            WatchQiblaMessage(
                systemImage: "location.slash",
                title: String(localized: "qibla_denied_title"),
                message: String(localized: "watch_qibla_denied_message")
            )
        case .headingUnavailable:
            WatchQiblaMessage(
                systemImage: "location.north.line",
                title: String(localized: "qibla_unavailable_title"),
                message: String(localized: "watch_qibla_unavailable_message")
            )
        case .locating:
            VStack(spacing: 8) {
                ProgressView()
                Text(String(localized: "qibla_locating_title"))
                    .font(.headline)
                Text(String(localized: "watch_qibla_locating_message"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        case .ready:
            compass
        }
    }

    private var compass: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(viewModel.isAligned ? 0.5 : 0.2), lineWidth: 2)
                Image(systemName: "arrow.up")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(viewModel.isAligned ? .white : Color.lightGreen)
                    .rotationEffect(.degrees(viewModel.arrowRotation))
                    .animation(.interpolatingSpring(stiffness: 120, damping: 18), value: viewModel.arrowRotation)
            }
            .frame(width: 100, height: 100)
            .accessibilityHidden(true)

            Text(viewModel.isAligned ? String(localized: "qibla_aligned_title") : viewModel.offsetText)
                .font(.title3.bold())
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(viewModel.guidanceText)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))

            if viewModel.needsCalibration {
                Text(String(localized: "watch_qibla_calibration_hint"))
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                    .multilineTextAlignment(.center)
            } else if let distanceText = viewModel.distanceText {
                Text(distanceText)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WatchQiblaMessage: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(Color.lightGreen)
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .tint(.lightGreen)
                }
            }
            .padding()
        }
    }
}
