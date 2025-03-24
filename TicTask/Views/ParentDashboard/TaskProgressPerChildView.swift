//
//  TaskProgressPerChildView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-23.
//


import SwiftUI

struct TaskProgressPerChildView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(authViewModel.childrenUsers, id: \.id) { child in
                let allTasks = taskViewModel.childrenTasks.filter { $0.assignedTo == child.id }
                let calendar = Calendar.current
                let thisWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!

                let tasks = allTasks.filter {
                    guard let deadline = $0.deadline else { return false }
                    return thisWeek.contains(deadline)
                }

                let completed = tasks.filter { $0.isCompleted }
                let total = tasks.count
                let progress = total > 0 ? Double(completed.count) / Double(total) : 1.0

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(child.name)")
                        .font(.headline)

                    if total > 0 {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "#64B5F6"))
                                .frame(width: CGFloat(progress) * 200, height: 10)
                        }
                        .frame(width: 200)

                        Text("\(Int(progress * 100))% klart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("✅ Inga uppgifter denna vecka")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}
