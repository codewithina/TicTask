//
//  TaskService.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import FirebaseFirestore

class TaskService {
    static let shared = TaskService()
    private let db = Firestore.firestore()
    
    func addTask(title: String, description: String, deadline: Date?, xpReward: Int, createdBy: String, assignedTo: String, completion: @escaping (Result<Task, Error>) -> Void) {
        let taskID = UUID().uuidString // Create unique ID
        
        let taskData: [String: Any] = [
            "id": taskID,
            "title": title,
            "description": description,
            "deadline": deadline != nil ? Timestamp(date: deadline!) : NSNull(),
            "xpReward": xpReward,
            "status": "pending",
            "createdBy": createdBy,
            "assignedTo": assignedTo,
            "timestamp": Timestamp()
        ]
        
        db.collection("tasks").document(taskID).setData(taskData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let task = Task(id: taskID, title: title, description: description, deadline: deadline, xpReward: xpReward, status: "pending", assignedTo: assignedTo, createdBy: createdBy)
                completion(.success(task))
            }
        }
    }
    
    func fetchTasks(for userID: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        db.collection("tasks").whereField("assignedTo", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                var tasks: [Task] = []
                if let documents = snapshot?.documents {
                    for document in documents {
                        do {
                            let task = try document.data(as: Task.self)
                            tasks.append(task)
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
                completion(.success(tasks))
            }
        }
    }
    
    func fetchTasksForChildren(childrenIDs: [String], completion: @escaping (Result<[Task], Error>) -> Void) {
        let tasksCollection = db.collection("tasks")
        let query = tasksCollection.whereField("assignedTo", in: childrenIDs)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                var tasks: [Task] = []
                if let documents = snapshot?.documents {
                    for document in documents {
                        do {
                            let task = try document.data(as: Task.self)
                            tasks.append(task)
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
                completion(.success(tasks))
            }
        }
    }
    
    func updateTaskStatus(taskID: String, status: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("tasks").document(taskID).updateData(["status": status]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateUserXP(userID: String, xpReward: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("🔴 Misslyckades att hämta barnets XP: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            let currentXP = snapshot?.data()?["xp"] as? Int ?? 0
            let newXP = currentXP + xpReward
            
            userRef.updateData(["xp": newXP]) { error in
                if let error = error {
                    print("🔴 Misslyckades att uppdatera XP: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Barnets XP uppdaterat! Ny XP: \(newXP)")
                    completion(.success(()))
                }
            }
        }
    }
    
    func listenForTasks(for userID: String, completion: @escaping ([Task]) -> Void) {
        let tasksCollection = db.collection("tasks")
        
        tasksCollection.whereField("assignedTo", isEqualTo: userID).addSnapshotListener { snapshot, error in
            if let error = error {
                print("🔴 Firestore realtidsuppdatering misslyckades: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("🟡 Inga uppgifter hittades för användare \(userID)")
                completion([])
                return
            }
            
            var tasks: [Task] = []
            for document in documents {
                do {
                    let task = try document.data(as: Task.self)
                    tasks.append(task)
                } catch {
                    print("🔴 Kunde inte konvertera uppgift: \(error.localizedDescription)")
                }
            }
            completion(tasks)
        }
    }
}
