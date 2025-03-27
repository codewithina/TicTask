//
//  TaskDeadlineStatusView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-24.
//
import SwiftUI

struct TaskDeadlineStatusView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(authViewModel.childrenUsers, id: \.id) { child in
                let tasks = taskViewModel.childrenTasks.filter { $0.assignedTo == child.id && !$0.isCompleted }
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
                
                let missed = tasks.filter {
                    guard let deadline = $0.deadline else { return false }
                    return deadline < today
                }
                
                let dueToday = tasks.filter {
                    guard let deadline = $0.deadline else { return false }
                    return calendar.isDate(deadline, inSameDayAs: today)
                }
                
                let dueTomorrow = tasks.filter {
                    guard let deadline = $0.deadline else { return false }
                    return calendar.isDate(deadline, inSameDayAs: tomorrow)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(child.name)")
                        .font(.headline)
                    
                    if !missed.isEmpty {
                        Text("🔴 Missade: \(missed.count)")
                            .font(.caption)
                    }
                    
                    if !dueToday.isEmpty {
                        Text("🟡 Deadline idag: \(dueToday.count)")
                            .font(.caption)
                    }
                    
                    if !dueTomorrow.isEmpty {
                        Text("🟢 Deadline imorgon: \(dueTomorrow.count)")
                            .font(.caption)
                    }
                    
                    if missed.isEmpty && dueToday.isEmpty && dueTomorrow.isEmpty {
                        Text("🔵 Inga akuta uppgifter")
                            .font(.caption)
                    }
                }
            }
        }
    }
}
