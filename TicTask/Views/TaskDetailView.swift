//
//  TaskDetailView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-04.
//

import SwiftUI

struct TaskDetailView: View {
    var task: Task
    @EnvironmentObject var taskViewModel: TaskViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(task.title)
                .font(.largeTitle)
                .bold()
            
            Text(task.description)
                .font(.body)
            
            Text("XP: \(task.xpReward)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()

            if !task.isCompleted {
                Button(action: {
                    taskViewModel.markTaskAsCompleted(taskID: task.id)
                }) {
                    Text("Markera som Klar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("✅ Slutförd!")
                    .font(.title)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .navigationTitle("Läxdetaljer")
    }
}
