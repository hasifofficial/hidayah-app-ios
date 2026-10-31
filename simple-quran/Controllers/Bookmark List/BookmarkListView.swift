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
                List {
                    ForEach(0..<10, id: \.self) { _ in
                        ListRowPlaceholder()
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            } else if viewModel.bookmarks.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.bookmarks) { bookmark in
                        Button {
                            onSelect?(bookmark)
                        } label: {
                            SurahRowView(
                                title: bookmark.surah.englishName ?? "",
                                subtitle: subtitle(for: bookmark),
                                arabicTitle: bookmark.surah.name ?? ""
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
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
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(
                    NSLocalizedString(
                        "bookmark_list_search_empty_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "bookmark")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "bookmark_list_search_empty_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
