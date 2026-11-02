//
//  SurahListView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

struct SurahListView: View {
    let viewModel: SurahListViewModel
    var onSelect: ((SurahListResponse) -> Void)? = nil
    var onOpenBookmarks: (() -> Void)? = nil
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.surahs.isEmpty {
                loadingState
            } else if viewModel.surahs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        quickAccess
                            .loadAnimation()
                            .padding(.bottom, 10)

                        listHeader
                            .loadAnimation(delay: 0.05)
                            .padding(.bottom, 6)

                        ForEach(viewModel.surahs.indices, id: \.self) { index in
                            let surah = viewModel.surahs[index]

                            Button {
                                onSelect?(surah)
                            } label: {
                                SurahListRowView(
                                    title: surah.englishName ?? "",
                                    subtitle: subtitle(for: surah),
                                    arabicTitle: surah.name ?? "",
                                    badgeText: String(surah.number ?? index + 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .loadAnimation(
                                delay: min(Double(index) * 0.025, 0.3),
                                offset: 10
                            )
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                .background(.appBackground)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle(
            NSLocalizedString(
                "surah_list_header_title",
                comment: ""
            )
        )
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    onOpenBookmarks?()
                } label: {
                    Image(systemName: "bookmark")
                        .foregroundColor(.primary)
                }
                .accessibilityLabel(
                    NSLocalizedString(
                        "bookmark_list_header_title",
                        comment: ""
                    )
                )

                Button {
                    onOpenSettings?()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
        .task {
            viewModel.loadIfNeeded()
        }
    }

    private var quickSurahs: [SurahListResponse] {
        let numbers = [18, 32, 36, 56, 67]
        return numbers.compactMap { number in
            viewModel.surahs.first { $0.number == number }
        }
    }

    private var quickAccess: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(
                    NSLocalizedString(
                        "surah_list_quick_access_title",
                        comment: ""
                    )
                )
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.title)

                Spacer()
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quickSurahs, id: \.number) { surah in
                        Button {
                            onSelect?(surah)
                        } label: {
                            quickAccessCard(surah)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .defaultScrollAnchor(.leading)
        }
    }

    private func quickAccessCard(_ surah: SurahListResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.lightGreen.opacity(0.14))

                    Text("\(surah.number ?? 0)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 28, height: 28)

                Spacer()

                Image(systemName: "book.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.lightGreen.opacity(0.75))
            }

            Text(surah.englishName ?? "")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.title)
                .lineLimit(1)

            Text(surah.name ?? "")
                .font(.kitabBold(size: 20))
                .foregroundColor(.lightGreen)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(width: 142, alignment: .leading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
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
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.14), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(surah.englishName ?? ""), \(surah.name ?? "")"
        )
    }

    private var listHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(NSLocalizedString("surah_list_all_title", comment: ""))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.title)

            Spacer()

            Text(
                String(
                    format: NSLocalizedString(
                        "surah_list_count_format",
                        comment: ""
                    ),
                    viewModel.surahs.count
                )
            )
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.textGray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var loadingState: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { _ in
                    ListRowPlaceholder()
                        .background(Color.backgroundGray)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                }
            }
            .padding(.top, 8)
        }
        .background(.appBackground)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(
                    NSLocalizedString(
                        "surah_list_empty_list_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "book.closed")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "surah_list_empty_list_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
    }

    private func subtitle(for surah: SurahListResponse) -> String {
        let origin = surah.revelationType?.lowercased() == "meccan"
            ? "Makiyyah"
            : "Madaniyah"

        return String(
            format: NSLocalizedString(
                "surah_list_subtitle",
                comment: ""
            ),
            origin,
            String(surah.numberOfAyahs ?? 0)
        )
    }
}
