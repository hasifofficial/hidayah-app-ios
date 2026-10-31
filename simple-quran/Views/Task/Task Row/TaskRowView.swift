//
//  TaskRowView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskDetails

    @Environment(TaskManager.self) private var taskManager
    @Binding var isEditing: Bool

    var body: some View {
        HStack {
            if isEditing {
                NavigationLink(destination: EditTaskView(task: task).environment(taskManager)) {
                    HStack {
                        Text(task.name)
                            .font(
                                .system(
                                    size: 15
                                )
                            )
                            .strikethrough(task.isCompleted)
                            .foregroundColor(.title)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "pencil")
                            .foregroundColor(.textGray)
                    }
                }
            } else {
                Button(action: {
                    taskManager.toggleTaskCompletion(task: task)
                }) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .lightGreen : .gray)
                        
                        Text(task.name)
                            .font(.system(size: 15))
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .textGray : .title)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .contentShape(Rectangle())
    }
}
