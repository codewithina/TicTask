//
//  ComboTaskListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-09.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddTaskView = false
    
    var isParent: Bool {
        authViewModel.user?.role == "parent"
    }
    
    var tasks: [Task] {
        isParent ? taskViewModel.childrenTasks : taskViewModel.tasks
    }
    
    var title: String {
        isParent ? "Barnens Läxor" : "Mina Läxor"
    }
    
    var emptyMessage: String {
        isParent ? "Dina barn har inga läxor ännu." : "Du har inga läxor ännu."
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if tasks.isEmpty {
                    Text(emptyMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(tasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)
                                    if isParent {
                                        Text("Barn: \(authViewModel.childrenNames[task.assignedTo] ?? "Okänt namn")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Text(task.description)
                                        .font(.subheadline)
                                    Text("Deadline: \(task.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "Ingen deadline")")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                Spacer()
                                if task.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
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
                    print("🟢 \(title) laddas, startar Firestore-lyssnare...")
                    taskViewModel.startListeningForTasks(for: user)
                }
            }
        }
    }
}
