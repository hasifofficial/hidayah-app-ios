//
//  TrackerTaskRowView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerTaskRowView: View {
    let task: TaskDetails

    @Environment(TaskManager.self) private var taskManager
    @Binding var isEditing: Bool

    var body: some View {
        Group {
            if isEditing {
                NavigationLink {
                    EditTaskView(task: task)
                        .environment(taskManager)
                } label: {
                    rowContent(showsPencil: true)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        taskManager.toggleTaskCompletion(task: task)
                    }
                } label: {
                    rowContent(showsPencil: false)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
    }

    private func rowContent(showsPencil: Bool) -> some View {
        HStack(alignment: .center, spacing: 12) {
            if !showsPencil {
                Image(
                    systemName: task.isCompleted
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(
                    task.isCompleted ? .lightGreen : .textGray.opacity(0.55)
                )
            }

            Text(task.name)
                .font(.system(size: 15))
                .foregroundColor(task.isCompleted ? .textGray : .title)
                .strikethrough(task.isCompleted)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if showsPencil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textGray)
            }
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }
}
