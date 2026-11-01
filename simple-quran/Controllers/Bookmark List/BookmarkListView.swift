//
//  BookmarkListView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/31/24.
//

import SwiftUI

struct BookmarkListView: View {
    let viewModel: BookmarkListViewModel
    var onSelect: ((BookmarkedSurah) -> Void)? = nil
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.bookmarks.isEmpty {
                loadingState
            } else if viewModel.bookmarks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        bookmarkSummary
                            .loadAnimation()
                            .padding(.bottom, 6)

                        ForEach(viewModel.bookmarks.indices, id: \.self) { index in
                            let bookmark = viewModel.bookmarks[index]
                            Button {
                                onSelect?(bookmark)
                            } label: {
                                SurahRowView(
                                    title: bookmark.surah.englishName ?? "",
                                    subtitle: subtitle(for: bookmark),
                                    arabicTitle: bookmark.surah.name ?? "",
                                    badgeIcon: "bookmark.fill"
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
                "bookmark_list_header_title",
                comment: ""
            )
        )
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onOpenSettings?()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }

    private var bookmarkSummary: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.lightGreen.opacity(0.14))

                Image(systemName: "bookmark.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.lightGreen)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(
                    NSLocalizedString(
                        "bookmark_list_saved_title",
                        comment: ""
                    )
                )
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.title)

                Text(
                    String(
                        format: NSLocalizedString(
                            "bookmark_list_count_format",
                            comment: ""
                        ),
                        viewModel.bookmarks.count
                    )
                )
                .font(.system(size: 12))
                .foregroundColor(.textGray)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
        .padding(.horizontal, 16)
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
                        "bookmark_list_empty_list_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "bookmark")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "bookmark_list_empty_list_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
    }

    private func subtitle(for bookmark: BookmarkedSurah) -> String {
        return String(
            format: NSLocalizedString(
                "bookmark_list_subtitle",
                comment: ""
            ),
            String(bookmark.bookmark.numberInSurah)
        )
    }
}
