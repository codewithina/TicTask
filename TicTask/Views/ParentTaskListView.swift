//
//  ParentTaskListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ParentTaskListView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddTaskView = false

    var body: some View {
        NavigationStack {
            VStack {
                if taskViewModel.childrenTasks.isEmpty {
                    Text("Dina barn har inga läxor ännu.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(taskViewModel.childrenTasks) { task in
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text("Barn: \(task.assignedTo)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(task.description)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Barnens Läxor")
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
                if let parent = authViewModel.user {
                    taskViewModel.fetchChildrenTasks(for: parent)
                }
            }
        }
    }
}


#Preview {
    ParentTaskListView()
}
