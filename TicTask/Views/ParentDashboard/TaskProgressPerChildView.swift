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
                let active = tasks.filter { !$0.isCompleted }
                let total = tasks.count
                let progress = total > 0 ? Double(completed.count) / Double(total) : 1.0

                let startOfToday = calendar.startOfDay(for: Date())
                let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)

                let missedDeadline = active.filter {
                    guard let deadline = $0.deadline else { return false }
                    return deadline < startOfToday
                }

                let deadlineToday = active.filter {
                    guard let deadline = $0.deadline else { return false }
                    return calendar.isDate(calendar.startOfDay(for: deadline), inSameDayAs: startOfToday)
                }

                let deadlineTomorrow = active.filter {
                    guard let deadline = $0.deadline else { return false }
                    return calendar.isDate(calendar.startOfDay(for: deadline), inSameDayAs: startOfTomorrow)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(child.name)")
                        .font(.headline)

                    if total > 0 {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue)
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

                    if !missedDeadline.isEmpty {
                        Text("🔴 Missade deadline: \(missedDeadline.count)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    if !deadlineToday.isEmpty {
                        Text("⚠️ Deadline idag: \(deadlineToday.count)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if !deadlineTomorrow.isEmpty {
                        Text("⏰ Deadline imorgon: \(deadlineTomorrow.count)")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}
