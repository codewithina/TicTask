//
//  TaskViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI
import FirebaseFirestore

class TaskViewModel: ObservableObject {
    static let shared = TaskViewModel()
    
    @Published var tasks: [Task] = []
    @Published var errorMessage: String?
    @Published var childrenTasks: [Task] = []
    @Published var isListening: Bool = false
    
    func addTask(title: String, description: String, deadline: Date?, xpReward: Int, createdBy: String, assignedTo: String) {
        TaskService.shared.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: createdBy, assignedTo: assignedTo) { result in
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
                    self.fetchTaskXPAndUpdateUser(taskID: taskID)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func startListeningForTasks(for user: User) {
        if isListening {
            print("🟡 Redan lyssnar, avbryter ytterligare lyssning")
            return
        }
        isListening = true
        TaskService.shared.listenForTasks(for: user.id) { newTasks in
            DispatchQueue.main.async {
                self.tasks = newTasks
            }
        }
        
        if user.role == "parent", let children = user.children {
            for childID in children {
                TaskService.shared.listenForTasks(for: childID) { newTasks in
                    DispatchQueue.main.async {
                        self.childrenTasks.append(contentsOf: newTasks)
                    }
                }
            }
        }
    }
    
    private func fetchTaskXPAndUpdateUser(taskID: String) {
        let taskRef = Firestore.firestore().collection("tasks").document(taskID)
        
        taskRef.getDocument { snapshot, error in
            if let error = error {
                print("🔴 Misslyckades att hämta uppgiftsdata: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let assignedTo = data["assignedTo"] as? String,
                  let xpReward = data["xpReward"] as? Int else {
                print("🔴 Kunde inte hämta uppgiftens XP eller assignedTo")
                return
            }
            
            TaskService.shared.updateUserXP(userID: assignedTo, xpReward: xpReward) { result in
                switch result {
                case .success:
                    print("✅ XP uppdaterat för \(assignedTo)!")
                case .failure(let error):
                    print("🔴 Fel vid XP-uppdatering: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
