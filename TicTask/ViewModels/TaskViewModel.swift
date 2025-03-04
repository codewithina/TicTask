//
//  TaskViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var errorMessage: String?

    func addTask(title: String, description: String, xpReward: Int, createdBy: String, assignedTo: String) {
        TaskService.shared.addTask(title: title, description: description, xpReward: xpReward, createdBy: createdBy, assignedTo: assignedTo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Läxa tillagd!")
                    self.fetchTasks(for: assignedTo)
                case .failure(let error):
                    print("🔴 Fel vid tillägg av läxa: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchTasks(for userID: String) {
        TaskService.shared.fetchTasks(for: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func markTaskAsCompleted(taskID: String) {
        TaskService.shared.updateTaskStatus(taskID: taskID, status: "completed") { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Läxa markerad som klar!")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
