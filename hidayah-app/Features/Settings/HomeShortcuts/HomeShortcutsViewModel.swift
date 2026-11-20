//
//  HomeShortcutsViewModel.swift
//  hidayah-app
//

import Foundation
import Observation

/// Picks and orders the Home shortcuts, saving every change straight away.
@MainActor
@Observable
final class HomeShortcutsViewModel {
    private(set) var selected: [AppFeature]

    @ObservationIgnored private let store: UserDefaults?

    init(store: UserDefaults? = Storage.userDefaults) {
        self.store = store
        self.selected = HomeShortcuts.load(from: store)
    }

    /// Features not on Home yet, in Explore order.
    var available: [AppFeature] {
        AppFeature.allCases.filter { !selected.contains($0) }
    }

    var canAdd: Bool {
        selected.count < HomeShortcuts.limit
    }

    /// Home always keeps at least one shortcut beside "All".
    var canRemove: Bool {
        selected.count > 1
    }

    var isDefault: Bool {
        selected == HomeShortcuts.defaults
    }

    func add(_ feature: AppFeature) {
        guard canAdd, !selected.contains(feature) else { return }
        selected.append(feature)
        save()
    }

    func remove(_ feature: AppFeature) {
        guard canRemove, let index = selected.firstIndex(of: feature) else { return }
        selected.remove(at: index)
        save()
    }

    func remove(atOffsets offsets: IndexSet) {
        guard selected.count - offsets.count >= 1 else { return }
        selected.remove(atOffsets: offsets)
        save()
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        selected.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func resetToDefault() {
        selected = HomeShortcuts.defaults
        save()
    }

    private func save() {
        HomeShortcuts.save(selected, to: store)
    }
}
