//
//  TaskCardView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct TaskCardView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var isEditing = false

    let category: Category
    var tasks: [TaskDetails] {
        taskManager.tasks(for: category)
    }
    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text(category.name)
                        .font(.system(size: 14, weight: .semibold))
                } icon: {
                    Image(systemName: category.icon)
                        .foregroundColor(Color(uiColor: .title))
                }
                
                Spacer()
                
                Text("\(completedCount)/\(tasks.count)")
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .textGray))

                Button(action: {
                    withAnimation {
                        isEditing.toggle()
                    }
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .lightGreen))
                }
            }
            
            Divider()
            
            ForEach(taskManager.tasks(for: category)) { task in
                TaskRowView(task: task, isEditing: $isEditing)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            taskManager.deleteTask(
                                task: task
                            )
                        } label: {
                            Label(
                                "Delete",
                                systemImage: "trash"
                            )
                        }
                    }
            }
        }
        .padding()
        .background(Color(uiColor: .backgroundGray))
        .cornerRadius(10)
    }
}
