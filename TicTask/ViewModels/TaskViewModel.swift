//
//  TaskViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI
import FirebaseFirestore

class TaskViewModel: ObservableObject {
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
            completedDate: nil,
            assignedTo: assignedTo,
            createdBy: createdBy,
            iconName: iconName,
            colorHex: colorHex
        )
        
        TaskService.shared.addTask(newTask) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    
                    guard let notificationViewModel = self.notificationViewModel else {
                        return
                    }
                    guard let user = self.authViewModel?.user else {
                        return
                    }
                    let creatorName = user.name
                    
                    // If parent adds a task  → Sen notification to child
                    if createdBy != assignedTo {
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
    
    func deleteTask(task: Task) {
        TaskService.shared.deleteTask(taskID: task.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.tasks.removeAll { $0.id == task.id }
                    
                    guard let user = self.authViewModel?.user else { return }
                    let userName = user.name
                    
                    if user.id == task.createdBy {
                        self.notificationViewModel?.sendNotification(
                            to: task.assignedTo,
                            message: "\(userName) har tagit bort läxan \"\(task.title)\"."
                        )
                    } else {
                        self.notificationViewModel?.sendNotification(
                            to: task.createdBy,
                            message: "\(userName) har tagit bort läxan \"\(task.title)\"."
                        )
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func markTaskAsCompleted(task: Task) {
        TaskService.shared.updateTaskStatus(taskID: task.id, status: "completed") { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    
                    guard let user = self.authViewModel?.user else { return }
                    
                    let now = Date()
                    
                    if user.role == "child" {
                        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                            self.tasks[index].status = "completed"
                            self.tasks[index].completedDate = now
                        }
                    } else if user.role == "parent" {
                        if let index = self.childrenTasks.firstIndex(where: { $0.id == task.id }) {
                            self.childrenTasks[index].status = "completed"
                            self.childrenTasks[index].completedDate = now
                        }
                    }
                    
                    self.fetchTaskXPAndUpdateUser(taskID: task.id)
                    
                    let baseXPEvent = XPEvent(
                        title: "Klarade \"\(task.title)\" 🚀",
                        xp: task.xpReward,
                        date: now,
                        type: .baseTask
                    )
                    
                    XPLogService.shared.logXPEvent(userID: user.id ?? "", event: baseXPEvent)
                    
                    XPBonusManager.shared.applyBonuses(
                        for: task,
                        user: user,
                        completedAt: now,
                        allCompletedTasks: self.tasks.filter {
                            $0.assignedTo == user.id && $0.isCompleted
                        }
                    )
                    
                    let userName = user.name
                    
                    // If child complete task → Send notification to parents
                    if user.id == task.assignedTo {
                        let parentIDs = user.parentIDs ?? []
                        if parentIDs.isEmpty {
                            print("⚠️ Barnet har inga kopplade föräldrar. Ingen notis skickas.")
                        } else {
                            for parentID in parentIDs {
                                self.notificationViewModel?.sendNotification(
                                    to: parentID,
                                    message: "\(userName) har markerat läxan \"\(task.title)\" som klar!"
                                )
                            }
                        }
                    }
                    
                    // If parent complete task → Send notification to child
                    if user.role == "parent" {
                        self.notificationViewModel?.sendNotification(
                            to: task.assignedTo,
                            message: "\(user.name) har markerat läxan \"\(task.title)\" som klar!"
                        )
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func startListeningForTasks(for user: User) {
        tasks = []
        childrenTasks = []
        
        if let userID = user.id {
            TaskService.shared.listenForTasks(for: userID) { newTasks in
                DispatchQueue.main.async {
                    self.tasks = newTasks
                    self.isListening = true
                }
            }
        } else {
            print("🚨 `user.id` är nil – kan inte lyssna på uppgifter")
        }
        
        if user.role == "parent", let children = user.children {
            for childID in children {
                TaskService.shared.listenForTasks(for: childID) { newTasks in
                    DispatchQueue.main.async {
                        self.childrenTasks.removeAll { $0.assignedTo == childID }
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
    
    func calculateStreakDays(for user: User) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let userID = user.id ?? ""
        
        // deadline today/earlier
        let pastTasks = tasks.filter {
            $0.assignedTo == userID &&
            ($0.deadline ?? .distantFuture) <= today
        }

        // latest missed task
        var latestFailedTaskCompletionDate: Date? = nil

        for task in pastTasks {
            guard let deadline = task.deadline else { continue }

            if let completed = task.completedDate {
                if completed > deadline {
                    if latestFailedTaskCompletionDate == nil || completed > latestFailedTaskCompletionDate! {
                        latestFailedTaskCompletionDate = completed
                    }
                }
            } else {
                // task never done
                if latestFailedTaskCompletionDate == nil || today > latestFailedTaskCompletionDate! {
                    latestFailedTaskCompletionDate = today
                }
            }
        }

        let streakStartDate: Date

        if let failedDate = latestFailedTaskCompletionDate {
            // streak start one day after completed
            streakStartDate = calendar.startOfDay(for: failedDate)
        } else {
            // 0 missed days, count from registered
            streakStartDate = calendar.startOfDay(for: user.registeredAt)
        }

        // count from streakStartDate 
        let streak = calendar.dateComponents([.day], from: streakStartDate, to: today).day ?? 0
        return max(0, streak)
    }
}
