//
//  TrackerCategoryCardView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerCategoryCardView: View {
    @Environment(TaskManager.self) private var taskManager
    @State private var isEditing = false

    let category: Category

    private var tasks: [TaskDetails] {
        taskManager.tasks(for: category)
    }

    private var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(tasks.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.lightGreen.opacity(0.12))

                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.title)

                    Text(
                        String(
                            format: NSLocalizedString(
                                "tracker_tasks_completed_format",
                                comment: ""
                            ),
                            completedCount,
                            tasks.count
                        )
                    )
                    .font(.system(size: 11))
                    .foregroundColor(.textGray)
                }

                Spacer(minLength: 8)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing.toggle()
                    }
                } label: {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.lightGreen)
                        .frame(width: 30, height: 30)
                        .background(Color.lightGreen.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isEditing
                        ? NSLocalizedString("tracker_edit_done", comment: "")
                        : NSLocalizedString("tracker_edit", comment: "")
                )
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.textGray.opacity(0.14))

                    Capsule()
                        .fill(Color.lightGreen)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 5)
            .animation(.easeInOut(duration: 0.25), value: progress)

            VStack(spacing: 2) {
                ForEach(tasks) { task in
                    TrackerTaskRowView(task: task, isEditing: $isEditing)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                taskManager.deleteTask(task: task)
                            } label: {
                                Label(NSLocalizedString("common_delete", comment: ""), systemImage: "trash")
                            }
                        }
                }
            }
        }
        .padding(16)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
        }
    }
}
