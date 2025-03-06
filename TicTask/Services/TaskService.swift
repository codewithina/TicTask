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

    func addTask(title: String, description: String, xpReward: Int, createdBy: String, assignedTo: String, completion: @escaping (Result<Task, Error>) -> Void) {
        let taskID = UUID().uuidString // Create unique ID

        let taskData: [String: Any] = [
            "id": taskID,
            "title": title,
            "description": description,
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
                let task = Task(id: taskID, title: title, description: description, xpReward: xpReward, status: "pending", assignedTo: assignedTo, createdBy: createdBy)
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
}
