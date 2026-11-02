//
//  HidayahStore.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
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
    var completedCount: Int = 0
    var totalCount: Int = 0
    var points: Int = 0

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

        return TrackerStorageSnapshot(
            tasks: tasks,
            customCategories: customCategories,
            history: loadHistorySummaries(),
            activeDayKey: Storage.load(key: .trackerActiveDayKey) as? String,
            startDayKey: Storage.load(key: .trackerStartDayKey) as? String
        )
    }

    func saveTasks(
        _ tasks: [TaskDetails],
        changedIDs: Set<UUID>? = nil,
        deletedIDs: Set<UUID> = []
    ) {
        let existing = fetch(FetchDescriptor<StoredTask>())
        var remaining = Dictionary(
            uniqueKeysWithValues: existing.map { ($0.id, $0) }
        )

        for id in deletedIDs {
            if let stored = remaining.removeValue(forKey: id) {
                context.delete(stored)
            }
        }

        for (index, task) in tasks.enumerated() {
            let shouldWrite = changedIDs == nil
                || changedIDs?.contains(task.id) == true
                || remaining[task.id] == nil
            guard shouldWrite else { continue }

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

        if changedIDs == nil {
            for stored in remaining.values {
                context.delete(stored)
            }
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
            existing.completedCount = record.completedCount
            existing.totalCount = record.totalCount
            existing.points = record.points
        } else {
            let stored = StoredDay(dayKey: key, payload: data)
            stored.completedCount = record.completedCount
            stored.totalCount = record.totalCount
            stored.points = record.points
            context.insert(stored)
        }
        save()
    }

    func loadHistorySummaries() -> [TrackerDayRecord] {
        let storedDays = fetch(
            FetchDescriptor<StoredDay>(
                sortBy: [SortDescriptor(\.dayKey)]
            )
        )
        var needsSave = false

        let summaries = storedDays.map { stored -> TrackerDayRecord in
            if stored.totalCount > 0 {
                return TrackerDayRecord(
                    dayKey: stored.dayKey,
                    completedCount: stored.completedCount,
                    totalCount: stored.totalCount,
                    points: stored.points
                )
            }

            if let full = try? JSONDecoder().decode(
                TrackerDayRecord.self,
                from: stored.payload
            ) {
                stored.completedCount = full.completedCount
                stored.totalCount = full.totalCount
                stored.points = full.points
                needsSave = true
                return full
            }

            return TrackerDayRecord(
                dayKey: stored.dayKey,
                completedCount: 0,
                totalCount: 0,
                points: 0
            )
        }

        if needsSave {
            save()
        }
        return summaries
    }

    func deleteDay(_ dayKey: String) {
        var descriptor = FetchDescriptor<StoredDay>(
            predicate: #Predicate { $0.dayKey == dayKey }
        )
        descriptor.fetchLimit = 1

        if let stored = try? context.fetch(descriptor).first {
            context.delete(stored)
            save()
        }
    }

    func loadDay(_ dayKey: String) -> TrackerDayRecord? {
        var descriptor = FetchDescriptor<StoredDay>(
            predicate: #Predicate { $0.dayKey == dayKey }
        )
        descriptor.fetchLimit = 1

        guard let stored = try? context.fetch(descriptor).first,
              let record = try? JSONDecoder().decode(
                TrackerDayRecord.self,
                from: stored.payload
              ) else {
            return nil
        }
        return record
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
        let hasMigrated = Storage.load(
            key: .hasMigratedToSwiftData
        ) as? Bool ?? false

        guard !hasMigrated else { return }

        // Never delete existing data automatically. The old reset path was
        // destructive and caused data loss when the flag or App Group
        // container was recreated. Mark the store as ready and keep data.
        Storage.save(.hasMigratedToSwiftData, true)
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
