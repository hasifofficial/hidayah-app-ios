//
//  RootView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/31/24.
//

import SwiftUI
import Observation
import UIKit

enum AppTab: Int, Hashable, Identifiable {
    case quran
    case bookmark
    case tracker
    case search

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .quran:
            return NSLocalizedString(
                "surah_list_header_title",
                comment: ""
            )
        case .bookmark:
            return NSLocalizedString(
                "bookmark_list_header_title",
                comment: ""
            )
        case .tracker:
            return NSLocalizedString(
                "tracker_list_tab_bar_title",
                comment: ""
            )
        case .search:
            return NSLocalizedString(
                "search_header_title",
                comment: ""
            )
        }
    }

    var icon: String {
        switch self {
        case .quran:
            return "book"
        case .bookmark:
            return "bookmark"
        case .tracker:
            return "checklist.unchecked"
        case .search:
            return "magnifyingglass"
        }
    }
}

struct RootView: View {
    private let surahService: SurahService
    private let taskManager: TaskManager

    @Bindable private var router: AppRouter

    @State private var quranViewModel: SurahListViewModel
    @State private var bookmarkViewModel: BookmarkListViewModel
    @State private var searchViewModel: SearchViewModel

    init(
        surahService: SurahService,
        taskManager: TaskManager,
        router: AppRouter
    ) {
        self.surahService = surahService
        self.taskManager = taskManager
        self.router = router

        let quranViewModel = SurahListViewModel(
            surahService: surahService
        )
        let bookmarkViewModel = BookmarkListViewModel(
            surahService: surahService
        )
        let searchViewModel = SearchViewModel(
            surahService: surahService
        )

        quranViewModel.onError = { [router] message in
            router.errorMessage = message
        }
        bookmarkViewModel.onError = { [router] message in
            router.errorMessage = message
        }
        searchViewModel.onError = { [router] message in
            router.errorMessage = message
        }

        searchViewModel.onSelectSurah = { [router] surah in
            guard let surahNumber = surah.number else { return }

            router.searchPath.append(
                .surahDetail(
                    surahNumber: surahNumber,
                    title: surah.englishName,
                    bookmarkedAyah: nil
                )
            )
        }

        searchViewModel.onSelectBookmark = { [router] item in
            guard let surahNumber = item.surah.number else { return }

            router.searchPath.append(
                .surahDetail(
                    surahNumber: surahNumber,
                    title: item.surah.englishName,
                    bookmarkedAyah: item.bookmark.numberInSurah
                )
            )
        }

        _quranViewModel = State(initialValue: quranViewModel)
        _bookmarkViewModel = State(initialValue: bookmarkViewModel)
        _searchViewModel = State(initialValue: searchViewModel)
    }

    var body: some View {
        legacyTabView
        .tint(.lightGreen)
        .environment(taskManager)
        .sheet(isPresented: $router.settingsPresented) {
            SettingsSheet(
                surahService: surahService,
                taskManager: taskManager
            )
            .presentationBackground(.sheetBackground)
            .environment(taskManager)
        }
        .alert(
            router.errorMessage ?? "",
            isPresented: Binding(
                get: { router.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        router.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK") {
                router.errorMessage = nil
            }
        }
    }

    private var legacyTabView: some View {
        TabView(selection: $router.selectedTab) {
            quranTab
                .tabItem {
                    tabLabel(.quran)
                }
                .tag(AppTab.quran)

            bookmarkTab
                .tabItem {
                    tabLabel(.bookmark)
                }
                .tag(AppTab.bookmark)

            trackerTab
                .tabItem {
                    tabLabel(.tracker)
                }
                .tag(AppTab.tracker)

            searchTab
                .tabItem {
                    tabLabel(.search)
                }
                .tag(AppTab.search)
        }
        .background(TabBarIconConfigurator())
    }

    private func tabLabel(_ tab: AppTab) -> some View {
        Label {
            Text(tab.title)
        } icon: {
            tabImage(tab.icon)
        }
    }

    private func tabImage(_ systemName: String) -> Image {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: 22,
            weight: .regular
        )

        guard let symbol = UIImage(
            systemName: systemName,
            withConfiguration: configuration
        ) else {
            return Image(systemName: systemName)
        }

        let renderer = UIGraphicsImageRenderer(size: symbol.size)
        let image = renderer.image { _ in
            symbol.draw(at: .zero)
        }

        return Image(
            uiImage: image.withRenderingMode(.alwaysTemplate)
        )
    }

    private var quranTab: some View {
        NavigationStack(path: $router.quranPath) {
            SurahListView(
                viewModel: quranViewModel,
                onSelect: { surah in
                    guard let surahNumber = surah.number else { return }

                    router.quranPath.append(
                        .surahDetail(
                            surahNumber: surahNumber,
                            title: surah.englishName,
                            bookmarkedAyah: nil
                        )
                    )
                },
                onOpenSettings: {
                    router.settingsPresented = true
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    private var bookmarkTab: some View {
        NavigationStack(path: $router.bookmarkPath) {
            BookmarkListView(
                viewModel: bookmarkViewModel,
                onSelect: { bookmark in
                    guard let surahNumber = bookmark.surah.number else { return }

                    router.bookmarkPath.append(
                        .surahDetail(
                            surahNumber: surahNumber,
                            title: bookmark.surah.englishName,
                            bookmarkedAyah: bookmark.bookmark.numberInSurah
                        )
                    )
                },
                onOpenSettings: {
                    router.settingsPresented = true
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    private var trackerTab: some View {
        NavigationStack {
            TrackerListView(
                taskManager: taskManager,
                onOpenSettings: {
                    router.settingsPresented = true
                }
            )
        }
    }

    private var searchTab: some View {
        NavigationStack(path: $router.searchPath) {
            SearchView(viewModel: searchViewModel)
                .navigationTitle(AppTab.search.title)
                .navigationBarTitleDisplayMode(.large)
                .searchable(
                    text: Binding(
                        get: { searchViewModel.keyword },
                        set: { searchViewModel.updateKeyword($0) }
                    ),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text(
                        NSLocalizedString(
                            "search_textfield_placeholder",
                            comment: ""
                        )
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            router.settingsPresented = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onAppear {
                    searchViewModel.loadIfNeeded()
                }
                .onChange(of: router.searchPath) { _, path in
                    if path.isEmpty {
                        searchViewModel.refreshBookmarks()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .surahDetail(let surahNumber, let title, let bookmarkedAyah):
            SurahDetailScreen(
                surahService: surahService,
                surahNumber: surahNumber,
                title: title,
                bookmarkedAyah: bookmarkedAyah
            )
        }
    }
}

private struct SettingsSheet: View {
    let taskManager: TaskManager

    @Environment(\.dismiss) private var dismiss
    @State private var path: [SettingsRoute] = []
    @State private var viewModel: SettingsViewModel
    @State private var errorMessage: String?

    init(
        surahService: SurahService,
        taskManager: TaskManager
    ) {
        self.taskManager = taskManager
        _viewModel = State(
            initialValue: SettingsViewModel(
                surahService: surahService
            )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsView(
                viewModel: viewModel,
                onOpenTrackerSettings: {
                    path.append(.trackerSettings)
                }
            )
            .navigationTitle(
                NSLocalizedString(
                    "setting_header_title",
                    comment: ""
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .trackerSettings:
                    TrackerSettingsView(
                        onManageCategories: {
                            path.append(.manageCategories)
                        },
                        onResetDailyProgress: {
                            taskManager.resetDailyTasks()
                            popToSettings()
                        },
                        onResetAll: {
                            taskManager.resetAll()
                            popToSettings()
                        }
                    )
                    .navigationTitle(
                        NSLocalizedString(
                            "setting_tracker_header_title",
                            comment: ""
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                case .manageCategories:
                    ManageCategoryView(
                        taskManager: taskManager
                    )
                }
            }
        }
        .interactiveDismissDisabled()
        .environment(taskManager)
        .task {
            viewModel.loadEditionsIfNeeded()
        }
        .onAppear {
            viewModel.onError = { message in
                errorMessage = message
            }
        }
        .alert(
            errorMessage ?? "",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK") {
                errorMessage = nil
            }
        }
    }

    private func popToSettings() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

private struct TabBarIconConfigurator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        DispatchQueue.main.async {
            configure()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            configure()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            configure()
        }
    }

    private func configure() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
              let rootViewController = windowScene.windows
            .first(where: \.isKeyWindow)?
            .rootViewController,
              let tabBarController = findTabBarController(
                in: rootViewController
              ),
              let items = tabBarController.tabBar.items,
              items.count >= 4 else {
            return
        }

        let icons = [
            ("book", "book.fill"),
            ("bookmark", "bookmark.fill"),
            ("checklist.unchecked", "checklist.checked"),
            ("magnifyingglass", "magnifyingglass")
        ]

        for (index, icon) in icons.enumerated() where index < items.count {
            let item = items[index]

            item.image = UIImage(
                systemName: icon.0
            )?.withRenderingMode(.alwaysTemplate)
            item.selectedImage = UIImage(
                systemName: icon.1
            )?.withRenderingMode(.alwaysTemplate)
        }
    }

    private func findTabBarController(
        in viewController: UIViewController
    ) -> UITabBarController? {
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }

        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }

        return nil
    }
}
