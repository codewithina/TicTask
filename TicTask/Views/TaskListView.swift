//
//  TaskListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddTaskView = false

    var body: some View {
        NavigationStack {
            List(taskViewModel.tasks) { task in
                NavigationLink(destination: TaskDetailView(task: task)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Mina Läxor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTaskView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(showAddTaskView: $showAddTaskView)
            }
            .onAppear {
                if let user = authViewModel.user {
                    taskViewModel.fetchTasks(for: user.id)
                }
            }
        }
    }
}

#Preview {
    TaskListView()
}
