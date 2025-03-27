//
//  XPLogService.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.
//

import FirebaseFirestore

class XPLogService {
    static let shared = XPLogService()
    private var listener: ListenerRegistration?
    
    func listenToXPLog(for userID: String, completion: @escaping ([XPEvent]) -> Void) {
        listener = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("xpLog")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let events = documents.compactMap { doc -> XPEvent? in
                    try? doc.data(as: XPEvent.self)
                }
                
                completion(events)
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func logXPEvent(userID: String, event: XPEvent) {
        let ref = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("xpLog")
        
        do {
            _ = try ref.addDocument(from: event)
        } catch {
            print("🔴 Kunde inte spara XPEvent: \(error.localizedDescription)")
        }
    }
}
