//
//  HidayahStore.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import SwiftData
import OSLog

// MARK: - Schema

/// The current store layout. Before changing any `@Model` below, freeze this
/// version by nesting copies of the current models inside it, add
/// `HidayahSchemaV2` with the new models, and add a stage to
/// `HidayahMigrationPlan`. Changing a model without a new version makes the
/// on-disk store fail to open.
enum HidayahSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            StoredTask.self,
            StoredCategory.self,
            StoredDay.self,
            StoredBookmark.self
        ]
    }
}

enum HidayahMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HidayahSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

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

    enum StoreError: LocalizedError {
        case appGroupUnavailable

        var errorDescription: String? {
            switch self {
            case .appGroupUnavailable:
                return "App Group container is unavailable."
            }
        }
    }

    /// Why the on-disk store could not be opened, or nil when it is open.
    /// While this is set the store runs in memory: nothing written to it
    /// survives a relaunch, and shared preferences are left untouched so the
    /// data on disk stays authoritative.
    private(set) var loadError: Error?

    var isPersistent: Bool {
        loadError == nil
    }

    private var context: ModelContext

    private static let logger = Logger(
        subsystem: "com.hasifofficial.simple-quran",
        category: "HidayahStore"
    )

    private static let schema = Schema(
        versionedSchema: HidayahSchemaV1.self
    )

    private init() {
        do {
            context = ModelContext(try Self.makePersistentContainer())
        } catch {
            Self.logger.fault(
                "Failed to open store: \(String(describing: error), privacy: .public)"
            )
            loadError = error
            context = ModelContext(Self.makeInMemoryContainer())
        }

        if isPersistent {
            prepareStorageIfNeeded()
        }
    }

    /// Retries opening the on-disk store after an earlier failure, e.g. one
    /// caused by the device being locked when the widget started. Anything
    /// written to the in-memory store in the meantime is discarded.
    @discardableResult
    func reconnectIfNeeded() -> Bool {
        guard !isPersistent else { return true }

        do {
            context = ModelContext(try Self.makePersistentContainer())
            loadError = nil
            prepareStorageIfNeeded()
            Self.logger.notice("Reconnected to on-disk store")
            return true
        } catch {
            loadError = error
            return false
        }
    }

    private static func makePersistentContainer() throws -> ModelContainer {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.hasifofficial.simple-quran"
        ) else {
            throw StoreError.appGroupUnavailable
        }

        let configuration = ModelConfiguration(
            schema: schema,
            url: groupURL.appendingPathComponent("Hidayah.store")
        )

        return try ModelContainer(
            for: schema,
            migrationPlan: HidayahMigrationPlan.self,
            configurations: [configuration]
        )
    }

    private static func makeInMemoryContainer() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        // An in-memory store has no file to fail on, so a throw here means
        // the schema itself is invalid.
        return try! ModelContainer(
            for: schema,
            configurations: [configuration]
        )
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
        guard isPersistent else { return }

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
        save()

        guard isPersistent else { return }

        Storage.delete(.trackerActiveDayKey)
        Storage.delete(.trackerStartDayKey)
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
        do {
            try context.save()
        } catch {
            Self.logger.error(
                "Failed to save store: \(String(describing: error), privacy: .public)"
            )
        }
    }
}
