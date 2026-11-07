//
//  TaskManager.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import WidgetKit
import Observation

@MainActor
@Observable
class TaskManager {
    var tasks: [TaskDetails] = []
    var customCategories: [CustomCategory] = []
    var history: [TrackerDayRecord] = []
    var activeDayKey: String?
    var startDayKey: String?

    static let shared = TaskManager()

    @ObservationIgnored
    private let historyEngine = TrackerHistoryEngine()

    @ObservationIgnored
    private let store: HidayahStore

    @ObservationIgnored
    private let scheduler: TrackerNotificationScheduler

    @ObservationIgnored
    private let now: () -> Date

    @ObservationIgnored
    private var dirtyTaskIDs: Set<UUID> = []

    @ObservationIgnored
    private var deletedTaskIDs: Set<UUID> = []

    @ObservationIgnored
    private var cachedStats: TrackerStats?

    @ObservationIgnored
    private var historyLookup: [String: TrackerDayRecord] = [:]

    @ObservationIgnored
    private var lastWidgetData: Data?

    @ObservationIgnored
    private var widgetReloadWorkItem: DispatchWorkItem?

    @ObservationIgnored
    private var dayChangeObserver: NSObjectProtocol?

    /// Fires at the next reset time, which need not be midnight.
    @ObservationIgnored
    private var dayStartTimer: Timer?

    init(
        store: HidayahStore = .shared,
        scheduler: TrackerNotificationScheduler = .shared,
        now: @escaping () -> Date = Date.init
    ) {
        self.store = store
        self.scheduler = scheduler
        self.now = now
        loadTasks()

        // The shared instance lives as long as the process, so the observer
        // is never removed.
        dayChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.refreshForCurrentDay()
            }
        }
    }

    func loadTasks() {
        store.reconnectIfNeeded()
        loadSavedData()

        if tasks.isEmpty {
            loadDefaultTasks()
        }

        if activeDayKey == nil {
            activeDayKey = todayKey
        }
        if startDayKey == nil {
            startDayKey = activeDayKey
        }

        upsertTodayRecord()
        refreshForCurrentDay()
        invalidateStats()
        updateWidget()
    }

    func refreshForCurrentDay() {
        let today = todayKey
        defer { scheduleDayStartTimer() }

        // Only move forward: a later reset time can make "today" earlier
        // than the day already in progress.
        if let activeDayKey, today <= activeDayKey { return }

        if activeDayKey == nil {
            activeDayKey = today
            if startDayKey == nil {
                startDayKey = today
            }
            saveData()
            return
        }

        let previousDayKey = activeDayKey
        activeDayKey = historyEngine.rollover(
            activeDayKey: activeDayKey,
            tasks: &tasks,
            history: &history,
            now: now()
        )
        dirtyTaskIDs.formUnion(tasks.map(\.id))
        invalidateStats()

        if startDayKey == nil {
            startDayKey = previousDayKey
        }

        saveData()
    }

    /// Minutes after midnight when a new tracker day starts.
    var dayStartMinutes: Int {
        TrackerDayKey.dayStartMinutes
    }

    /// Saves a new reset time and moves to the day it puts the tracker on.
    func setDayStartMinutes(_ minutes: Int) {
        guard TrackerDayKey.dayStartChoices.contains(minutes),
              minutes != TrackerDayKey.dayStartMinutes else { return }
        TrackerDayKey.dayStartMinutes = minutes
        refreshForCurrentDay()
        invalidateStats()
        // The widget's snapshot may be unchanged, but its timeline was built
        // around the old reset time, so always ask it to rebuild.
        lastWidgetData = nil
        updateWidget()
    }

    private func scheduleDayStartTimer() {
        dayStartTimer?.invalidate()
        let current = now()
        guard let next = TrackerDayKey.nextDayStart(after: current) else { return }

        // Measured from the injected clock, so a fixed test clock never
        // schedules a time that has already passed.
        let delay = max(next.timeIntervalSince(current), 1)
        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.refreshForCurrentDay()
                self?.updateWidget()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        dayStartTimer = timer
    }

    var stats: TrackerStats {
        if let cachedStats {
            return cachedStats
        }
        let value = historyEngine.stats(for: history, now: now())
        cachedStats = value
        return value
    }

    private var todayKey: String {
        TrackerDayKey.today(now: now())
    }

    var todayRecord: TrackerDayRecord? {
        record(for: activeDayKey ?? todayKey)
    }

    func record(for dayKey: String) -> TrackerDayRecord? {
        if historyLookup.isEmpty && !history.isEmpty {
            rebuildHistoryLookup()
        }

        guard let record = historyLookup[dayKey] else {
            return nil
        }

        guard record.tasks.isEmpty, record.totalCount > 0 else {
            return record
        }

        guard let fullRecord = store.loadDay(dayKey) else {
            return record
        }

        if let index = history.firstIndex(where: { $0.dayKey == dayKey }) {
            history[index] = fullRecord
        }
        historyLookup[dayKey] = fullRecord
        return fullRecord
    }

    func records(in month: Date) -> [TrackerDayRecord] {
        let calendar = TrackerDayKey.calendar
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let start = calendar.date(from: components),
              let end = calendar.date(byAdding: .month, value: 1, to: start) else {
            return []
        }

        let startKey = TrackerDayKey.key(for: start)
        let endKey = TrackerDayKey.key(for: end)
        return history.filter { $0.dayKey >= startKey && $0.dayKey < endKey }
    }

    func upsertTodayRecord() {
        let dayKey = activeDayKey ?? todayKey
        let record = historyEngine.makeRecord(for: tasks, on: dayKey)
        historyEngine.upsert(record, for: dayKey, in: &history)
        invalidateStats()
    }

    func allCategories() -> [Category] {
        let defaultCategories = DefaultCategory.allCases.map { Category.default($0) }
        let customCategories = customCategories.map { Category.custom($0) }
        return defaultCategories + customCategories
    }
    
    func tasks(for category: Category) -> [TaskDetails] {
        tasks.filter { $0.category.id == category.id }
    }

    func saveData() {
        upsertTodayRecord()

        store.saveTasks(
            tasks,
            changedIDs: dirtyTaskIDs,
            deletedIDs: deletedTaskIDs
        )
        dirtyTaskIDs.removeAll()
        deletedTaskIDs.removeAll()
        store.saveCategories(customCategories)
        store.saveActiveState(
            activeDayKey: activeDayKey,
            startDayKey: startDayKey
        )

        if let todayRecord {
            store.saveDay(todayRecord)
        } else if let activeDayKey {
            store.deleteDay(activeDayKey)
        }

        updateWidget()
    }

    func addCustomCategory(
        name: String,
        icon: String = "folder"
    ) {
        let newCategory = CustomCategory(
            name: name,
            icon: icon
        )
        customCategories.append(newCategory)
        saveData()
    }
    
    func addTask(
        name: String,
        category: Category
    ) {
        let newTask = TaskDetails(
            name: name,
            category: category
        )
        tasks.append(newTask)
        dirtyTaskIDs.insert(newTask.id)
        saveData()
    }

    func deleteTask(
        task: TaskDetails
    ) {
        tasks.removeAll { $0.id == task.id }
        dirtyTaskIDs.remove(task.id)
        deletedTaskIDs.insert(task.id)
        saveData()
    }

    func updateTask(
        task: TaskDetails,
        newName: String,
        newCategory: Category
    ) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].name = newName
            tasks[index].category = newCategory
            dirtyTaskIDs.insert(task.id)
            saveData()
        }
    }

    func toggleTaskCompletion(
        task: TaskDetails
    ) {
        refreshForCurrentDay()

        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            dirtyTaskIDs.insert(task.id)
            saveData()
            scheduler.progressDidChange(
                record: todayRecord,
                stats: stats
            )
        }
    }

    func resetDailyTasks() {
        DispatchQueue.main.async {
            self.refreshForCurrentDay()

            for index in self.tasks.indices {
                self.tasks[index].isCompleted = false
            }
            self.dirtyTaskIDs.formUnion(self.tasks.map(\.id))

            let dayKey = self.activeDayKey ?? self.todayKey
            self.history.removeAll { $0.dayKey == dayKey }
            self.saveData()
            self.scheduler.clearMilestones()
        }
    }

    func resetAll() {
        store.resetTracker()
        Storage.delete(.trackerDayStartMinutes)

        tasks = []
        customCategories = []
        history = []
        activeDayKey = todayKey
        startDayKey = activeDayKey
        dirtyTaskIDs.removeAll()
        deletedTaskIDs.removeAll()
        invalidateStats()
        saveData()
        scheduler.clearAll()
        loadTasks()
    }

    private func invalidateStats() {
        cachedStats = nil
        rebuildHistoryLookup()
    }

    private func rebuildHistoryLookup() {
        historyLookup = Dictionary(
            uniqueKeysWithValues: history.map { ($0.dayKey, $0) }
        )
    }
}

extension TaskManager {
    private func loadDefaultTasks() {
        tasks = [
            TaskDetails(name: "Awakening do’a (All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection)", category: .default(.morning)),

            TaskDetails(name: "Taubah prayer with do’a", category: .default(.tahajjud)),
            TaskDetails(name: "Hajat prayer with do’a", category: .default(.tahajjud)),
            TaskDetails(name: "Tahajjud prayer with do'a", category: .default(.tahajjud)),
            TaskDetails(name: "Solawat 100x", category: .default(.tahajjud)),
            TaskDetails(name: "Istighfar 100x", category: .default(.tahajjud)),

            TaskDetails(name: "Dawn Alms (Sodaqah)", category: .default(.fajr)),
            TaskDetails(name: "Solawat 10x", category: .default(.fajr)),
            TaskDetails(name: "Recitation of Ayatul Qursi 1x", category: .default(.fajr)),
            TaskDetails(name: "Do'a to parents", category: .default(.fajr)),
            TaskDetails(name: "Qabliah Fajr", category: .default(.fajr)),
            TaskDetails(name: "Fajr prayer", category: .default(.fajr)),
            TaskDetails(name: "Istighfar 3x", category: .default(.fajr)),
            TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.fajr)),
            TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.fajr)),
            TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.fajr)),

            TaskDetails(name: "Recitation of Al-Mathurat (Kubra)", category: .default(.recitation)),
            TaskDetails(name: "Recitation of Surah Al-Waqi’ah", category: .default(.recitation)),
            TaskDetails(name: "Recitation of Surah Yasin", category: .default(.recitation)),
            TaskDetails(name: "Recitation of 30 ayats Al Quran", category: .default(.recitation)),

            TaskDetails(name: "Dhuha prayer with do’a", category: .default(.dhuha)),

            TaskDetails(name: "Qabliah Dhuhr", category: .default(.dhuhr)),
            TaskDetails(name: "Dhuhr prayer", category: .default(.dhuhr)),
            TaskDetails(name: "Istighfar 3x", category: .default(.dhuhr)),
            TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.dhuhr)),
            TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.dhuhr)),
            TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.dhuhr)),
            TaskDetails(name: "Do’a after Dhuhr", category: .default(.dhuhr)),
            TaskDetails(name: "Ba’diah Dhuhr", category: .default(.dhuhr)),

            TaskDetails(name: "Qabliah Asr", category: .default(.asr)),
            TaskDetails(name: "Asr prayer", category: .default(.asr)),
            TaskDetails(name: "Istighfar 3x", category: .default(.asr)),
            TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.asr)),
            TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.asr)),
            TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.asr)),
            TaskDetails(name: "Do’a after Asr", category: .default(.asr)),
            TaskDetails(name: "Recitation of Al-Mathurat (Kubra)", category: .default(.asr)),

            TaskDetails(name: "Qabliah Maghrib", category: .default(.maghrib)),
            TaskDetails(name: "Maghrib prayer", category: .default(.maghrib)),
            TaskDetails(name: "Istighfar 3x", category: .default(.maghrib)),
            TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.maghrib)),
            TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.maghrib)),
            TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.maghrib)),
            TaskDetails(name: "Do’a after Maghrib", category: .default(.maghrib)),
            TaskDetails(name: "Ba’diah Maghrib", category: .default(.maghrib)),
            TaskDetails(name: "Maghrib lecture", category: .default(.maghrib)),

            TaskDetails(name: "Qabliah Isha", category: .default(.isha)),
            TaskDetails(name: "Isha prayer", category: .default(.isha)),
            TaskDetails(name: "Istighfar 3x", category: .default(.isha)),
            TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.isha)),
            TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.isha)),
            TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.isha)),
            TaskDetails(name: "Do’a after Isha", category: .default(.isha)),
            TaskDetails(name: "Ba’diah Isha", category: .default(.isha)),
            TaskDetails(name: "Witr prayer", category: .default(.isha)),
            TaskDetails(name: "Recitation of Surah Al-Mulk", category: .default(.isha)),

            TaskDetails(name: "Set alarm and make do’a for Allah to wake you for Tahajjud.", category: .default(.bedtime)),
            TaskDetails(name: "Forgive everyone before sleeping", category: .default(.bedtime)),
            TaskDetails(name: "Bedtime do’a (In Your name O Allah, I live and die)", category: .default(.bedtime)),
            TaskDetails(name: "Recitation of 3 Qul", category: .default(.bedtime)),
            TaskDetails(name: "Recitation of Ayatul Qursi", category: .default(.bedtime)),
            TaskDetails(name: "Recitation of Surah Al-Fatihah", category: .default(.bedtime)),
            TaskDetails(name: "Istighfar 3x", category: .default(.bedtime)),
            TaskDetails(name: "Solawat 10x", category: .default(.bedtime)),
            TaskDetails(name: "Tasbih Subhanallah 33x", category: .default(.bedtime)),
            TaskDetails(name: "Tahmid Alhamdulillah 33x", category: .default(.bedtime)),
            TaskDetails(name: "Takbir AllahuAkbar 33x", category: .default(.bedtime)),
        ]
        dirtyTaskIDs = Set(tasks.map(\.id))
        saveData()
    }
    
    private func loadSavedData() {
        let snapshot = store.loadTrackerData()
        tasks = snapshot.tasks
        customCategories = snapshot.customCategories
        history = snapshot.history
        activeDayKey = snapshot.activeDayKey
        startDayKey = snapshot.startDayKey
        dirtyTaskIDs.removeAll()
        deletedTaskIDs.removeAll()
        invalidateStats()
    }
}

extension TaskManager {
    func updateWidget() {
        // An in-memory session must not replace the widget's snapshot of
        // the data that is still on disk.
        guard store.isPersistent else { return }

        let completed = tasks.filter { $0.isCompleted }.count
        let total = tasks.count
        let progress = total > 0
            ? Double(completed) / Double(total)
            : 0
        let upcomingTasks = tasks
            .filter { !$0.isCompleted }
            .prefix(5)
            .map { $0 }
        let resetUpcomingTasks = tasks
            .prefix(5)
            .map { task in
                var task = task
                task.isCompleted = false
                return task
            }

        let widgetContext = WidgetContext(
            progress: progress,
            completedTasks: completed,
            totalTasks: total,
            upcomingTasks: upcomingTasks,
            dayKey: activeDayKey ?? todayKey,
            resetUpcomingTasks: resetUpcomingTasks
        )
        guard let encoded = try? JSONEncoder().encode(widgetContext),
              encoded != lastWidgetData else {
            return
        }

        lastWidgetData = encoded
        Storage.save(.widgetContext, encoded)

        widgetReloadWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            WidgetCenter.shared.reloadAllTimelines()
        }
        widgetReloadWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.6,
            execute: workItem
        )
    }
}
