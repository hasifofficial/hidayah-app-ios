//
//  HidayahStore.swift
//  simple-quran
//

import Foundation
import SwiftData

@Model
final class StoredTask {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryID: String
    var isCompleted: Bool
    var sortOrder: Int

    init(
        id: UUID,
        name: String,
        categoryID: String,
        isCompleted: Bool,
        sortOrder: Int
    ) {
        self.id = id
        self.name = name
        self.categoryID = categoryID
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}

@Model
final class StoredCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var sortOrder: Int

    init(id: UUID, name: String, icon: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
    }
}

@Model
final class StoredDay {
    @Attribute(.unique) var dayKey: String
    var payload: Data
    var updatedAt: Date

    init(dayKey: String, payload: Data) {
        self.dayKey = dayKey
        self.payload = payload
        updatedAt = Date()
    }
}

@Model
final class StoredBookmark {
    @Attribute(.unique) var key: String
    var surahNumber: Int
    var numberInSurah: Int
    var createdAt: Date

    init(surahNumber: Int, numberInSurah: Int) {
        key = "\(surahNumber)-\(numberInSurah)"
        self.surahNumber = surahNumber
        self.numberInSurah = numberInSurah
        createdAt = Date()
    }
}

struct TrackerStorageSnapshot {
    let tasks: [TaskDetails]
    let customCategories: [CustomCategory]
    let history: [TrackerDayRecord]
    let activeDayKey: String?
    let startDayKey: String?
}

final class HidayahStore {
    static let shared = HidayahStore()

    let container: ModelContainer
    private let context: ModelContext

    private init() {
        let schema = Schema([
            StoredTask.self,
            StoredCategory.self,
            StoredDay.self,
            StoredBookmark.self
        ])

        let created: ModelContainer
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.hasifofficial.simple-quran"
        ) {
            let storeURL = groupURL.appendingPathComponent("Hidayah.store")
            let configuration = ModelConfiguration(
                schema: schema,
                url: storeURL
            )
            do {
                created = try ModelContainer(
                    for: schema,
                    configurations: [configuration]
                )
            } catch {
                let fallback = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                created = try! ModelContainer(
                    for: schema,
                    configurations: [fallback]
                )
            }
        } else {
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            created = try! ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        }

        container = created
        context = ModelContext(created)
        prepareStorageIfNeeded()
    }

    // MARK: - Tracker

    func loadTrackerData() -> TrackerStorageSnapshot {
        let storedCategories = fetch(
            FetchDescriptor<StoredCategory>(
                sortBy: [SortDescriptor(\.sortOrder)]
            )
        )
        let customCategories = storedCategories.map {
            CustomCategory(
                id: $0.id,
                name: $0.name,
                icon: $0.icon
            )
        }
        let categoryLookup = Dictionary(
            uniqueKeysWithValues: customCategories.map { ($0.id, $0) }
        )

        let storedTasks = fetch(
            FetchDescriptor<StoredTask>(
                sortBy: [SortDescriptor(\.sortOrder)]
            )
        )
        let tasks = storedTasks.compactMap { stored -> TaskDetails? in
            guard let category = category(for: stored.categoryID, custom: categoryLookup) else {
                return nil
            }
            return TaskDetails(
                id: stored.id,
                name: stored.name,
                category: category,
                isCompleted: stored.isCompleted
            )
        }

        let storedDays = fetch(
            FetchDescriptor<StoredDay>(
                sortBy: [SortDescriptor(\.dayKey)]
            )
        )
        let history = storedDays.compactMap {
            try? JSONDecoder().decode(TrackerDayRecord.self, from: $0.payload)
        }

        return TrackerStorageSnapshot(
            tasks: tasks,
            customCategories: customCategories,
            history: history,
            activeDayKey: Storage.load(key: .trackerActiveDayKey) as? String,
            startDayKey: Storage.load(key: .trackerStartDayKey) as? String
        )
    }

    func saveTasks(_ tasks: [TaskDetails]) {
        let existing = fetch(FetchDescriptor<StoredTask>())
        var remaining = Dictionary(
            uniqueKeysWithValues: existing.map { ($0.id, $0) }
        )

        for (index, task) in tasks.enumerated() {
            if let stored = remaining.removeValue(forKey: task.id) {
                stored.name = task.name
                stored.categoryID = task.category.id
                stored.isCompleted = task.isCompleted
                stored.sortOrder = index
            } else {
                context.insert(
                    StoredTask(
                        id: task.id,
                        name: task.name,
                        categoryID: task.category.id,
                        isCompleted: task.isCompleted,
                        sortOrder: index
                    )
                )
            }
        }

        for stored in remaining.values {
            context.delete(stored)
        }
        save()
    }

    func saveCategories(_ categories: [CustomCategory]) {
        let existing = fetch(FetchDescriptor<StoredCategory>())
        var remaining = Dictionary(
            uniqueKeysWithValues: existing.map { ($0.id, $0) }
        )

        for (index, category) in categories.enumerated() {
            if let stored = remaining.removeValue(forKey: category.id) {
                stored.name = category.name
                stored.icon = category.icon
                stored.sortOrder = index
            } else {
                context.insert(
                    StoredCategory(
                        id: category.id,
                        name: category.name,
                        icon: category.icon,
                        sortOrder: index
                    )
                )
            }
        }

        for stored in remaining.values {
            context.delete(stored)
        }
        save()
    }

    func saveDay(_ record: TrackerDayRecord) {
        guard let data = try? JSONEncoder().encode(record) else { return }

        let key = record.dayKey
        var descriptor = FetchDescriptor<StoredDay>(
            predicate: #Predicate { $0.dayKey == key }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            existing.payload = data
            existing.updatedAt = Date()
        } else {
            context.insert(StoredDay(dayKey: key, payload: data))
        }
        save()
    }

    func saveActiveState(activeDayKey: String?, startDayKey: String?) {
        if let activeDayKey {
            Storage.save(.trackerActiveDayKey, activeDayKey)
        }
        if let startDayKey {
            Storage.save(.trackerStartDayKey, startDayKey)
        }
    }

    func resetTracker() {
        deleteAll(StoredTask.self)
        deleteAll(StoredCategory.self)
        deleteAll(StoredDay.self)
        Storage.delete(.trackerActiveDayKey)
        Storage.delete(.trackerStartDayKey)
        save()
    }

    // MARK: - Bookmarks

    func bookmarks() -> [SurahBookmark] {
        let stored = fetch(
            FetchDescriptor<StoredBookmark>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
        )
        return stored.map {
            SurahBookmark(
                surahNumber: $0.surahNumber,
                numberInSurah: $0.numberInSurah
            )
        }
    }

    @discardableResult
    func toggleBookmark(_ bookmark: SurahBookmark) -> [SurahBookmark] {
        let key = "\(bookmark.surahNumber)-\(bookmark.numberInSurah)"
        var descriptor = FetchDescriptor<StoredBookmark>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
        } else {
            context.insert(
                StoredBookmark(
                    surahNumber: bookmark.surahNumber,
                    numberInSurah: bookmark.numberInSurah
                )
            )
        }
        save()
        return bookmarks()
    }

    // MARK: - Migration / Reset

    private func prepareStorageIfNeeded() {
        removeLegacyStorageKeys()

        let hasMigrated = Storage.load(
            key: .hasMigratedToSwiftData
        ) as? Bool ?? false

        guard !hasMigrated else { return }

        // This is a deliberate one-time reset. The previous local store is
        // cleared before SwiftData becomes the source of truth.
        deleteAll(StoredTask.self)
        deleteAll(StoredCategory.self)
        deleteAll(StoredDay.self)
        deleteAll(StoredBookmark.self)
        save()

        for key in Storage.StorageKey.allCases
            where key != .hasMigratedToSwiftData {
            Storage.delete(key)
        }

        Storage.save(.hasMigratedToSwiftData, true)
        Storage.userDefaults?.synchronize()
    }

    private func removeLegacyStorageKeys() {
        let legacyKeys = [
            "trackerContext",
            "bookmarkRecitations",
            "storageSchemaVersion"
        ]
        for key in legacyKeys {
            Storage.userDefaults?.removeObject(forKey: key)
        }
        Storage.userDefaults?.synchronize()
    }

    // MARK: - Helpers

    private func category(
        for id: String,
        custom: [UUID: CustomCategory]
    ) -> Category? {
        if id.hasPrefix("default_") {
            let rawValue = String(id.dropFirst("default_".count))
            guard let value = DefaultCategory(rawValue: rawValue) else {
                return nil
            }
            return .default(value)
        }

        if id.hasPrefix("custom_") {
            let uuidString = String(id.dropFirst("custom_".count))
            if let uuid = UUID(uuidString: uuidString),
               let value = custom[uuid] {
                return .custom(value)
            }
            return .custom(
                CustomCategory(
                    name: "Custom",
                    icon: "folder"
                )
            )
        }

        return nil
    }

    private func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) -> [T] {
        (try? context.fetch(descriptor)) ?? []
    }

    private func fetchCount<T: PersistentModel>(_ type: T.Type) -> Int {
        (try? context.fetchCount(FetchDescriptor<T>())) ?? 0
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) {
        guard let values = try? context.fetch(FetchDescriptor<T>()) else {
            return
        }
        for value in values {
            context.delete(value)
        }
    }

    private func save() {
        try? context.save()
    }
}
