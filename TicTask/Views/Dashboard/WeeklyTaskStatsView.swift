//
//  WeeklyTaskStatsView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-15.
//
import SwiftUI
import Firebase

struct WeeklyTaskStatsView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel

    var body: some View {
        SectionBox(title: "Veckans statistik") {
            VStack {
                Text("Slutförda uppgifter: ")
                    .font(.headline)
                    .padding()
                
                // Create \(taskViewModel.completedTasksThisWeek.count), develop statistics etc.
            }
        }
    }
}
