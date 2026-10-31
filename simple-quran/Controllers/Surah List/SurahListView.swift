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

struct SurahRowView: View {
    let title: String
    let subtitle: String
    let arabicTitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.textGray)
            }

            Spacer(minLength: 8)

            Text(arabicTitle)
                .font(.custom("Kitab-Bold", size: 22))
                .foregroundColor(.lightGreen)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

struct ListRowPlaceholder: View {
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 16) {
                    ShimmerBar()
                        .frame(width: proxy.size.width * 0.30, height: 12)

                    ShimmerBar()
                        .frame(width: proxy.size.width * 0.45, height: 12)
                }

                Spacer(minLength: 8)

                ShimmerBar()
                    .frame(width: proxy.size.width * 0.30, height: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(height: 76)
    }
}

struct ShimmerBar: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.placeholderGray)
                .overlay {
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.55),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * 0.6)
                    .offset(x: phase * proxy.size.width)
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .onAppear {
            phase = -1

            withAnimation(
                .linear(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1.6
            }
        }
    }
}
