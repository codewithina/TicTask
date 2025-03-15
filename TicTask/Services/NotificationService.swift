//
//  NotificationService.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import FirebaseFirestore

class NotificationService {
    static let shared = NotificationService()
    private let db = Firestore.firestore()
    
    private var listener: ListenerRegistration?
    
    private func userNotificationsRef(for userID: String) -> CollectionReference {
        return db.collection("users").document(userID).collection("notifications")
    }
    
    func startListeningForNotifications(for userID: String, completion: @escaping ([NotificationModel]) -> Void) {
        
        listener?.remove() 
        
        listener = userNotificationsRef(for: userID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("🔴 Misslyckades att hämta notiser i realtid: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ Inga notiser hittades i Firestore för användare \(userID).")
                    completion([])
                    return
                }
                
                let notifications = documents.compactMap { doc -> NotificationModel? in
                    var notification = try? doc.data(as: NotificationModel.self)
                    notification?.id = doc.documentID
                    return notification
                }
                
                print("📢 Firestore returnerade \(notifications.count) notiser för användare \(userID)")
                DispatchQueue.main.async {
                    completion(notifications)
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func sendNotification(to userID: String, message: String) {
        
        let notificationData: [String: Any] = [
            "message": message,
            "timestamp": Timestamp(date: Date())
        ]
        
        userNotificationsRef(for: userID).addDocument(data: notificationData) { error in
            if let error = error {
                print("🔴 Misslyckades att skicka notis till \(userID): \(error.localizedDescription)")
            } else {
                print("✅ Notis skickad till \(userID): \(message)")
            }
        }
    }
    
    func deleteNotification(for userID: String, notificationID: String) {
        userNotificationsRef(for: userID).document(notificationID).delete { error in
            if let error = error {
                print("🔴 Misslyckades att ta bort notis: \(error.localizedDescription)")
            } else {
                print("✅ Notis raderad")
            }
        }
    }
}


