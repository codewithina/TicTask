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
    var notificationViewModel: NotificationViewModel?
    var authViewModel: AuthViewModel?
    
    @Published var tasks: [Task] = []
    @Published var errorMessage: String?
    @Published var childrenTasks: [Task] = []
    @Published var isListening: Bool = false
    
    func addTask(title: String, description: String, deadline: Date?, xpReward: Int, createdBy: String, assignedTo: String, parentIDs: [String], iconName: String, colorHex: String) {
        let newTask = Task(
            id: UUID().uuidString,
            title: title,
            description: description,
            deadline: deadline,
            xpReward: xpReward,
            status: "pending",
            assignedTo: assignedTo,
            createdBy: createdBy,
            iconName: iconName,
            colorHex: colorHex
        )
        
        TaskService.shared.addTask(newTask) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Läxa tillagd!")

                    guard let notificationViewModel = self.notificationViewModel else {
                        print("❌ `notificationViewModel` är nil! Kan inte skicka notiser.")
                        return
                    }

                    //Change the creatorname from id to name
                    let creatorName = createdBy

                    // If parent adds a task  → Sen notification to child
                    if createdBy != assignedTo {
                        print("📩 Skickar notis till barnet: \(assignedTo)")
                        notificationViewModel.sendNotification(
                            to: assignedTo,
                            message: "Din förälder har lagt till en ny läxa: \(title)"
                        )
                    }

                    // If child adds a task  → Sen notification to parent
                    if createdBy == assignedTo {
                        if parentIDs.isEmpty {
                            print("⚠️ Barnet har inga kopplade föräldrar. Ingen notis skickas.")
                        } else {
                            for parentID in parentIDs {
                                print("📩 Skickar notis till förälder: \(parentID)")
                                notificationViewModel.sendNotification(
                                    to: parentID,
                                    message: "\(creatorName) har lagt till en ny läxa: \(title)"
                                )
                            }
                        }
                    }

                case .failure(let error):
                    print("🔴 Fel vid tillägg av läxa: \(error.localizedDescription)")
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
        
        if let userID = user.id {
            TaskService.shared.listenForTasks(for: userID) { newTasks in
                DispatchQueue.main.async {
                    self.tasks = newTasks
                }
            }
        } else {
            print("🚨 `user.id` är nil – kan inte lyssna på uppgifter")
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
