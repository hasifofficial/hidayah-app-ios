//
//  RootView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI
import Observation
import UIKit

enum AppTab: Int, Hashable, Identifiable, CaseIterable {
    case quran
    case tasbih
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
        case .tasbih:
            return NSLocalizedString(
                "tasbih_tab_title",
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
        case .tasbih:
            return "circle.grid.3x3"
        case .tracker:
            return "checklist.unchecked"
        case .search:
            return "magnifyingglass"
        }
    }

    var selectedIcon: String {
        switch self {
        case .quran:
            return "book.fill"
        case .tasbih:
            return "circle.grid.3x3.fill"
        case .tracker:
            return "checklist.checked"
        case .search:
            return "magnifyingglass"
        }
    }

    var assetIcon: String? {
        self == .tasbih ? "TasbihIcon" : nil
    }

    var selectedAssetIcon: String? {
        self == .tasbih ? "TasbihIconFill" : nil
    }
}

struct RootView: View {
    private let surahService: SurahService
    private let taskManager: TaskManager

    @Bindable private var router: AppRouter

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var useSplitView = false
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
        Group {
            if useSplitView {
                splitView
            } else {
                legacyTabView
            }
        }
        .tint(.lightGreen)
        .environment(router)
        .onAppear {
            updateLayoutForCurrentTraits()
        }
        .onChange(of: horizontalSizeClass) { _, _ in
            updateLayoutForCurrentTraits()
        }
        .onChange(of: hasPushedNavigation) { _, _ in
            updateLayoutForCurrentTraits()
        }
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

    private var hasPushedNavigation: Bool {
        !router.quranPath.isEmpty
            || !router.searchPath.isEmpty
            || !router.trackerPath.isEmpty
    }

    private func updateLayoutForCurrentTraits() {
        useSplitView = horizontalSizeClass == .regular
    }

    private var splitView: some View {
        NavigationSplitView {
            List(selection: selectedTabBinding) {
                ForEach(AppTab.allCases) { tab in
                    Label {
                        Text(tab.title)
                    } icon: {
                        tabIcon(
                            tab,
                            selected: router.selectedTab == tab
                        )
                    }
                    .tag(tab)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                sidebarLogo
            }
        } detail: {
            selectedTabContent
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ToolbarContentBuilder
    private var sidebarLogo: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) {
                sidebarLogoImage
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarLeading) {
                sidebarLogoImage
            }
        }
    }

    private var sidebarLogoImage: some View {
        Image("hidayah_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 96, height: 44)
            .accessibilityLabel("Hidayah")
    }

    private var tabSelectionBinding: Binding<AppTab> {
        Binding(
            get: { router.selectedTab },
            set: { router.selectTab($0, clearingPaths: useSplitView) }
        )
    }

    private var selectedTabBinding: Binding<AppTab?> {
        Binding(
            get: { router.selectedTab },
            set: { selectedTab in
                if let selectedTab {
                    router.selectTab(selectedTab, clearingPaths: true)
                }
            }
        )
    }

    @ViewBuilder
    private var selectedTabContent: some View {
        switch router.selectedTab {
        case .quran:
            quranTab
        case .tasbih:
            tasbihTab
        case .tracker:
            trackerTab
        case .search:
            searchTab
        }
    }

    private var legacyTabView: some View {
        TabView(selection: tabSelectionBinding) {
            quranTab
                .tabItem {
                    tabLabel(.quran)
                }
                .tag(AppTab.quran)

            tasbihTab
                .tabItem {
                    tabLabel(.tasbih)
                }
                .tag(AppTab.tasbih)

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
            tabIcon(tab, selected: false)
        }
    }

    @ViewBuilder
    private func tabIcon(
        _ tab: AppTab,
        selected: Bool
    ) -> some View {
        if let assetName = selected
            ? tab.selectedAssetIcon
            : tab.assetIcon {
            Image(assetName)
                .renderingMode(.template)
        } else {
            tabImage(
                selected ? tab.selectedIcon : tab.icon
            )
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
                onOpenBookmarks: {
                    router.quranPath.append(.bookmarkList)
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

    private var tasbihTab: some View {
        NavigationStack {
            TasbihView(
                onOpenSettings: {
                    router.settingsPresented = true
                }
            )
        }
    }

    private var trackerTab: some View {
        NavigationStack(path: $router.trackerPath) {
            TrackerListView(
                taskManager: taskManager,
                onOpenCalendar: {
                    router.trackerPath.append(.trackerCalendar)
                },
                onOpenAchievements: {
                    router.trackerPath.append(.trackerAchievements)
                },
                onOpenLevels: {
                    router.trackerPath.append(.trackerLevels)
                },
                onOpenSettings: {
                    router.settingsPresented = true
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .surahDetail(let surahNumber, let title, let bookmarkedAyah):
                    SurahDetailScreen(
                        surahService: surahService,
                        surahNumber: surahNumber,
                        title: title,
                        bookmarkedAyah: bookmarkedAyah
                    )
                case .trackerCalendar:
                    TrackerCalendarView(
                        taskManager: taskManager,
                        onSelectDay: { dayKey in
                            router.trackerPath.append(.trackerDay(dayKey: dayKey))
                        }
                    )
                    .environment(taskManager)
                case .trackerAchievements:
                    TrackerAchievementsView(taskManager: taskManager)
                case .trackerLevels:
                    TrackerLevelsView(taskManager: taskManager)
                case .trackerDay(let dayKey):
                    TrackerDayDetailView(
                        taskManager: taskManager,
                        dayKey: dayKey,
                        record: taskManager.record(for: dayKey)
                    )
                case .bookmarkList:
                    bookmarkListDestination
                }
            }
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
                                .foregroundColor(.primary)
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
        case .trackerCalendar:
            TrackerCalendarView(
                taskManager: taskManager,
                onSelectDay: { dayKey in
                    router.trackerPath.append(.trackerDay(dayKey: dayKey))
                }
            )
            .environment(taskManager)
        case .trackerAchievements:
            TrackerAchievementsView(taskManager: taskManager)
        case .trackerLevels:
            TrackerLevelsView(taskManager: taskManager)
        case .trackerDay(let dayKey):
            TrackerDayDetailView(
                taskManager: taskManager,
                dayKey: dayKey,
                record: taskManager.record(for: dayKey)
            )
        case .bookmarkList:
            bookmarkListDestination
        }
    }

    private var bookmarkListDestination: some View {
        BookmarkListView(
            viewModel: bookmarkViewModel,
            onSelect: { bookmark in
                guard let surahNumber = bookmark.surah.number else { return }

                router.quranPath.append(
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

        let icons: [(UIImage?, UIImage?)] = [
            (
                UIImage(systemName: "book"),
                UIImage(systemName: "book.fill")
            ),
            (
                UIImage(named: "TasbihIcon"),
                UIImage(named: "TasbihIconFill")
            ),
            (
                UIImage(systemName: "checklist.unchecked"),
                UIImage(systemName: "checklist.checked")
            ),
            (
                UIImage(systemName: "magnifyingglass"),
                UIImage(systemName: "magnifyingglass")
            )
        ]

        for (index, icon) in icons.enumerated() where index < items.count {
            let item = items[index]
            item.image = icon.0?.withRenderingMode(.alwaysTemplate)
            item.selectedImage = icon.1?.withRenderingMode(.alwaysTemplate)
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
