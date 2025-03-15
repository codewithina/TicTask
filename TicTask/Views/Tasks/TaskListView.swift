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
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: task.colorHex).opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: task.iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color(hex: task.colorHex))
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(task.title)
                                        .font(.headline)
                                        .lineLimit(1)

                                    if isParent {
                                        Text("Barn: \(authViewModel.childrenUsers.first(where: { $0.id == task.assignedTo })?.name ?? "Okänt namn")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

                                    Text(task.description)
                                        .font(.subheadline)
                                        .lineLimit(2)

                                    Text("Deadline: \(task.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "Ingen deadline")")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 5)
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
        }
    }
}
