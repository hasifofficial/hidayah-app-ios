//
//  SurahListView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import SwiftUI

struct SurahListView: View {
    let viewModel: SurahListViewModel
    var onSelect: ((SurahListResponse) -> Void)? = nil
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.surahs.isEmpty {
                List {
                    ForEach(0..<10, id: \.self) { _ in
                        ListRowPlaceholder()
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            } else if viewModel.surahs.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.surahs.indices, id: \.self) { index in
                        let surah = viewModel.surahs[index]

                        Button {
                            onSelect?(surah)
                        } label: {
                            SurahRowView(
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
                }
                .listStyle(.plain)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onOpenSettings?()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
        }
        .task {
            viewModel.loadIfNeeded()
        }
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
