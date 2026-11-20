//
//  QiblaView.swift
//  hidayah-app
//

import SwiftUI
import UIKit

/// A full-screen Qibla finder in the style of Precision Finding: a big
/// arrow and degree readout on black, turning green with a pulsing disc
/// once the user faces the Qibla.
struct QiblaView: View {
    let viewModel: QiblaViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            background

            switch viewModel.status {
            case .ready:
                compass
            case .locating:
                locating
            case .needsPermission:
                QiblaMessageView(
                    icon: "location.circle",
                    title: NSLocalizedString("qibla_permission_title", comment: ""),
                    message: NSLocalizedString("qibla_permission_message", comment: ""),
                    actionTitle: NSLocalizedString("qibla_permission_action", comment: ""),
                    action: viewModel.requestPermission
                )
            case .denied:
                QiblaMessageView(
                    icon: "location.slash",
                    title: NSLocalizedString("qibla_denied_title", comment: ""),
                    message: NSLocalizedString("qibla_denied_message", comment: ""),
                    actionTitle: NSLocalizedString("qibla_denied_action", comment: ""),
                    action: openSettings
                )
            case .headingUnavailable:
                QiblaMessageView(
                    icon: "safari",
                    title: NSLocalizedString("qibla_unavailable_title", comment: ""),
                    message: NSLocalizedString("qibla_unavailable_message", comment: "")
                )
            }
        }
        .navigationTitle(NSLocalizedString("qibla_header_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                header
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .tint(.white)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            viewModel.onAppear()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            viewModel.onDisappear()
        }
    }

    // MARK: Pieces

    private var background: some View {
        (viewModel.isAligned ? Color.lightGreen : Color.black)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: viewModel.isAligned)
    }

    private var header: some View {
        VStack(spacing: 1) {
            Text(NSLocalizedString("qibla_header_title", comment: ""))
                .font(.headline)
                .foregroundStyle(.white)
            if let distance = viewModel.distanceText {
                Text(distance)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .contentTransition(.numericText())
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var compass: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.needsCalibration {
                calibrationBanner
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            QiblaPointerView(
                rotation: viewModel.arrowRotation,
                closeness: viewModel.closeness,
                isAligned: viewModel.isAligned
            )
            .frame(maxWidth: 420, maxHeight: 420)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)

            readout
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.needsCalibration)
    }

    private var readout: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.isAligned {
                Text(NSLocalizedString("qibla_aligned_title", comment: ""))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text(viewModel.offsetText)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: viewModel.offset ?? 0))
                    .animation(.snappy, value: viewModel.offsetText)
            }

            Text(viewModel.guidanceText)
                .font(.title.weight(.semibold))
                .foregroundStyle(.white.opacity(viewModel.isAligned ? 0.9 : 0.6))

            if let bearing = viewModel.bearingText {
                Text(bearing)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .accessibilityElement(children: .combine)
    }

    private var calibrationBanner: some View {
        Label(
            NSLocalizedString("qibla_calibration_hint", comment: ""),
            systemImage: "infinity"
        )
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.black)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.yellow, in: Capsule())
    }

    private var locating: some View {
        ZStack {
            QiblaSearchingDots()
                .frame(maxWidth: 360, maxHeight: 360)
                .padding(24)

            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("qibla_locating_title", comment: ""))
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                    Text(NSLocalizedString("qibla_locating_message", comment: ""))
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
