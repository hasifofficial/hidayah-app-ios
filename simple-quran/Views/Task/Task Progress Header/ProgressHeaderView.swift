//
//  ProgressHeaderView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct ProgressHeaderView: View {
    @EnvironmentObject var taskManager: TaskManager

    var progress: Double {
        guard !taskManager.tasks.isEmpty else { return 0 }
        let completed = taskManager.tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(taskManager.tasks.count)
    }

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func todayIslamicDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamic)
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color(uiColor: .lightGreen))
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(uiColor: .lightGreen))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.title)
                        .bold()
                    Text("\(taskManager.tasks.filter { $0.isCompleted }.count)/\(taskManager.tasks.count) tasks")
                        .font(.caption)
                }
            }
            .frame(width: 120, height: 120)
            
            VStack(spacing: 4) {
                Text(todayDateString())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(uiColor: .title))

                Text(todayIslamicDateString())
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .textGray))
            }
            .padding(.top, 10)
        }
    }
}
