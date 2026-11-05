//
//  MathuratView.swift
//  simple-quran
//

import SwiftUI

struct MathuratView: View {
    nonisolated private static let scrollSpace = "mathuratScroll"
    private static let topID = "mathuratTop"
    /// Leaves room above a deep-linked entry for the progress banner.
    private static let focusTopMargin: CGFloat = 72

    let viewModel: MathuratViewModel
    /// The order of an entry to scroll to, set by a deep link and cleared
    /// once handled.
    var focusOrder: Binding<Int?> = .constant(nil)
    let onOpenSettings: () -> Void

    @Environment(\.scenePhase) private var scenePhase

    @State private var showingReadingSettings = false
    @State private var viewportHeight: CGFloat = 0
    @State private var contentFrame: CGRect = .zero
    @State private var isHeaderHidden = false

    @AppStorage(
        Storage.StorageKey.quranArabicFontSize.rawValue,
        store: Storage.userDefaults
    ) private var arabicFontSize = 22.0

    @AppStorage(
        Storage.StorageKey.quranShowTranslation.rawValue,
        store: Storage.userDefaults
    ) private var showTranslation = true

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // Not lazy: the read percentage needs the real content height,
                // and a session is only about 35 entries.
                VStack(spacing: 0) {
                    header
                        .id(Self.topID)
                        .loadAnimation(offset: 16)
                        .onGeometryChange(for: Bool.self) { geometry in
                            geometry.frame(in: .named(Self.scrollSpace)).maxY < 0
                        } action: { hidden in
                            withAnimation(.easeOut(duration: 0.2)) {
                                isHeaderHidden = hidden
                            }
                        }

                    if viewModel.loadError != nil {
                        errorState
                    } else if !viewModel.isLoaded {
                        placeholder
                    } else {
                        ForEach(
                            Array(viewModel.entries.enumerated()),
                            id: \.element.id
                        ) { index, entry in
                            // Marks the row's top edge for deep-link scrolling.
                            Color.clear
                                .frame(height: 0)
                                .id(Self.focusID(for: entry.id))

                            MathuratEntryRow(
                                entry: entry,
                                number: index + 1,
                                count: viewModel.count(for: entry),
                                arabicFontSize: arabicFontSize,
                                showTranslation: showTranslation,
                                shareText: viewModel.shareText(for: entry)
                            ) {
                                viewModel.increment(entry)
                            }
                            .loadAnimation(
                                delay: min(Double(index) * 0.02, 0.3),
                                offset: 12
                            )
                        }
                    }
                }
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100)
                .onGeometryChange(for: CGRect.self) { geometry in
                    geometry.frame(in: .named(Self.scrollSpace))
                } action: { frame in
                    contentFrame = frame
                    updateReadFraction()
                }
            }
            .coordinateSpace(.named(Self.scrollSpace))
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.height
            } action: { height in
                viewportHeight = height
                updateReadFraction()
            }
            .overlay(alignment: .top) {
                if isHeaderHidden && viewModel.isLoaded {
                    progressBanner {
                        withAnimation {
                            proxy.scrollTo(Self.topID, anchor: .top)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onAppear {
                scrollToFocusedEntry(proxy)
            }
            .onChange(of: focusOrder.wrappedValue) {
                scrollToFocusedEntry(proxy)
            }
            .onChange(of: viewModel.isLoaded) {
                scrollToFocusedEntry(proxy)
            }
        }
        .background(.appBackground)
        .navigationTitle(NSLocalizedString("mathurat_header_title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingReadingSettings = true
                } label: {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.primary)
                }
                .accessibilityLabel(
                    NSLocalizedString("quran_reading_settings_title", comment: "")
                )

                Button(action: onOpenSettings) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            viewModel.refreshTime()
            viewModel.loadIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refreshTime()
            }
        }
        .task(id: viewModel.time) {
            try? await Task.sleep(for: .seconds(viewModel.secondsUntilTimeChange))
            guard !Task.isCancelled else { return }
            viewModel.refreshTime()
        }
        .sheet(isPresented: $showingReadingSettings) {
            ReadingSettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        ReaderHeaderCard(
            icon: viewModel.time.icon,
            label: NSLocalizedString(viewModel.time.labelKey, comment: ""),
            title: NSLocalizedString(viewModel.time.titleKey, comment: "")
        ) {
            Text(NSLocalizedString("mathurat_about", comment: ""))
                .font(.system(size: 13))
                .foregroundColor(.textGray)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: viewModel.progress)
                    .tint(.lightGreen)
                    .accessibilityHidden(true)

                Text(
                    String(
                        format: NSLocalizedString(
                            "mathurat_progress_completed_format",
                            comment: ""
                        ),
                        viewModel.progressPercent
                    )
                )
                .font(.system(size: 13, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(.lightGreen)
            }
        }
    }

    /// Shown pinned to the top once the header card scrolls away; tapping it
    /// scrolls back up.
    private func progressBanner(onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.time.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.lightGreen)

                    Text(NSLocalizedString(viewModel.time.titleKey, comment: ""))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.title)

                    Spacer(minLength: 8)

                    Text("\(viewModel.progressPercent)%")
                        .font(.system(size: 13, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(.lightGreen)
                }

                ProgressView(value: viewModel.progress)
                    .tint(.lightGreen)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                // The header card's gradient, on an opaque base so the text
                // scrolling underneath doesn't show through.
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 700)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityLabel(
            String(
                format: NSLocalizedString("mathurat_banner_accessibility", comment: ""),
                NSLocalizedString(viewModel.time.titleKey, comment: ""),
                viewModel.progressPercent
            )
        )
        .accessibilityHint(NSLocalizedString("mathurat_banner_hint", comment: ""))
    }

    private static func focusID(for entryID: Int) -> String {
        "mathuratEntry-\(entryID)"
    }

    /// Scrolls to the deep-linked entry once the session is loaded, looking
    /// the order up in the current session. An order the session doesn't
    /// have leaves the list at the top.
    private func scrollToFocusedEntry(_ proxy: ScrollViewProxy) {
        guard let order = focusOrder.wrappedValue, viewModel.isLoaded else { return }
        focusOrder.wrappedValue = nil
        guard let entryID = viewModel.entries.first(where: { $0.order == order })?.id else { return }

        // Wait a turn so the rows are laid out before scrolling.
        Task { @MainActor in
            await Task.yield()
            // Puts the row's top just below the progress banner rather than
            // under it.
            let anchorY = viewportHeight > 0
                ? min(Self.focusTopMargin / viewportHeight, 1)
                : 0
            withAnimation {
                proxy.scrollTo(
                    Self.focusID(for: entryID),
                    anchor: UnitPoint(x: 0.5, y: anchorY)
                )
            }
        }
    }

    /// Turns the scroll position into how far the session has been read:
    /// 0 at the top, 1 once the end of the list is on screen.
    private func updateReadFraction() {
        guard viewportHeight > 0, contentFrame.height > 0 else { return }

        let scrollable = contentFrame.height - viewportHeight
        let fraction = scrollable <= 0 ? 1 : Double(-contentFrame.minY / scrollable)
        viewModel.updateReadFraction(fraction)
    }

    private var errorState: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.lightGreen)

            Text(NSLocalizedString("mathurat_load_error", comment: ""))
                .font(.system(size: 15))
                .foregroundColor(.title)
                .multilineTextAlignment(.center)

            Button(NSLocalizedString("mathurat_retry", comment: "")) {
                viewModel.retry()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.lightGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 24)
    }

    private var placeholder: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.backgroundGray)
                        .frame(height: 46)

                    ShimmerBar()
                        .frame(height: 16)

                    ShimmerBar()
                        .frame(width: 200, height: 12)
                }
            }
        }
        .padding(16)
    }
}
