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
    
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("tasks").document(task.id).setData(from: task) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteTask(taskID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("tasks").document(taskID).delete { error in
            if let error = error {
                print("🔴 Misslyckades att ta bort uppgiften: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Uppgift borttagen!")
                completion(.success(()))
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
            
            let newTasks = snapshot?.documents.compactMap { doc -> Task? in
                try? doc.data(as: Task.self)
            } ?? []
            
            DispatchQueue.main.async {
                completion(newTasks)
            }
        }
    }
}
