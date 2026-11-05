//
//  TaskManager.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import WidgetKit

class TaskManager: ObservableObject {
    @Published var tasks: [TaskDetails] = []
    @Published var customCategories: [CustomCategory] = []

    static let shared = TaskManager()

    private init() {
        loadTasks()
    }
    
    func loadTasks() {
        loadSavedData()
        
        if tasks.isEmpty {
            loadDefaultTasks()
        }
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
        let trackerContext = TrackerContext(
            tasks: tasks,
            customCategories: customCategories
        )
        if let encoded = try? JSONEncoder().encode(trackerContext) {
            Storage.save(.trackerContext, encoded)
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
        saveData()
    }

    func deleteTask(
        task: TaskDetails
    ) {
        tasks.removeAll { $0.id == task.id }
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
            saveData()
        }
    }

    func toggleTaskCompletion(
        task: TaskDetails
    ) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveData()
        }
    }

    func resetDailyTasks() {
        DispatchQueue.main.async {
            for index in self.tasks.indices {
                self.tasks[index].isCompleted = false
            }
            self.saveData()
        }
    }
    
    func resetAll() {
        tasks = []
        customCategories = []
        saveData()
        loadTasks()
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
        saveData()
    }
    
    private func loadSavedData() {
        let trackerContext: TrackerContext? = Storage.loadObject(key: .trackerContext)
        if let trackerContext = trackerContext {
            tasks = trackerContext.tasks
            customCategories = trackerContext.customCategories
        }
    }
}

extension TaskManager {
    func updateWidget() {
        let completed = tasks.filter { $0.isCompleted }.count
        let total = tasks.count
        let progress = Double(completed) / Double(total)
        let upcomingTasks = tasks
            .filter { !$0.isCompleted }
            .prefix(3)
            .map { $0 }
        let widgetContext = WidgetContext(
            progress: progress,
            completedTasks: completed,
            totalTasks: total,
            upcomingTasks: upcomingTasks
        )
        if let encoded = try? JSONEncoder().encode(widgetContext) {
            Storage.save(.widgetContext, encoded)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
