//
//  SearchView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct SearchView: View {
    let viewModel: SearchViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.surahList.isEmpty {
                List {
                    ForEach(0..<10, id: \.self) { _ in
                        ListRowPlaceholder()
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            } else if viewModel.keyword.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty {
                emptyState
            } else if viewModel.filteredSurahList.isEmpty
                        && viewModel.filteredBookmarkedSurahs.isEmpty {
                emptyState
            } else {
                List {
                    if !viewModel.filteredBookmarkedSurahs.isEmpty {
                        Section {
                            ForEach(viewModel.filteredBookmarkedSurahs) { item in
                                Button {
                                    viewModel.onSelectBookmark?(item)
                                } label: {
                                    SurahListRowView(
                                        title: item.surah.englishName ?? "",
                                        subtitle: String(
                                            format: NSLocalizedString(
                                                "bookmark_list_subtitle",
                                                comment: ""
                                            ),
                                            String(item.bookmark.numberInSurah)
                                        ),
                                        arabicTitle: item.surah.name ?? ""
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        } header: {
                            sectionHeader("search_bookmarked_surah_section_title")
                        }
                    }

                    if !viewModel.filteredSurahList.isEmpty {
                        Section {
                            ForEach(viewModel.filteredSurahList, id: \.number) { surah in
                                Button {
                                    viewModel.onSelectSurah?(surah)
                                } label: {
                                    SurahListRowView(
                                        title: surah.englishName ?? "",
                                        subtitle: subtitle(for: surah),
                                        arabicTitle: surah.name ?? ""
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        } header: {
                            sectionHeader("search_surah_section_title")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(
                    NSLocalizedString(
                        "surah_list_search_empty_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "magnifyingglass")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "surah_list_search_empty_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sectionHeader(_ key: String) -> some View {
        Text(NSLocalizedString(key, comment: ""))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.title)
            .textCase(nil)
    }

    private func subtitle(for surah: SurahListResponse) -> String {
        let origin = surah.revelationType?.lowercased() == "meccan"
            ? NSLocalizedString("quran_revelation_makkan", comment: "")
            : NSLocalizedString("quran_revelation_madani", comment: "")

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
