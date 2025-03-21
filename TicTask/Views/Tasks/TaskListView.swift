//
//  TaskListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-09.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddTaskView = false
    @State private var showCompletedTasks = false

    var isParent: Bool {
        authViewModel.user?.role == "parent"
    }

    var tasks: [Task] {
        let unsortedTasks = isParent ? taskViewModel.childrenTasks : taskViewModel.tasks
        return unsortedTasks.sorted {
            ($0.deadline ?? Date.distantFuture) < ($1.deadline ?? Date.distantFuture)
        }
    }

    var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }

    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
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
                    List {
                        if !incompleteTasks.isEmpty {
                            Section(header: Text("Pågående läxor")) {
                                ForEach(incompleteTasks) { task in
                                    taskRow(task)
                                }
                            }
                        }

                        if !completedTasks.isEmpty {
                            Section(header: Text("Klara läxor")) {
                                Button(action: {
                                    withAnimation {
                                        showCompletedTasks.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("Visa alla")
                                        Spacer()
                                        Image(systemName: showCompletedTasks ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                if showCompletedTasks {
                                    ForEach(completedTasks) { task in
                                        taskRow(task)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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

    func taskRow(_ task: Task) -> some View {
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

                    if task.isCompleted {
                        Text("Uppgiften klar! 🎉")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        Text("Deadline: \(task.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "Ingen deadline")")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 5)
        }
    }
}
