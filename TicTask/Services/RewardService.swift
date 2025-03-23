//
//  RewardService.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-12.
//

import FirebaseFirestore

class RewardService {
    static let shared = RewardService()
    private let db = Firestore.firestore()
    
    func addReward(reward: Reward, completion: @escaping (Result<Void, Error>) -> Void) {
        var newReward = reward
        
        if newReward.id == nil {
            newReward.id = UUID().uuidString
        }
        
        do {
            try db.collection("rewards").document(newReward.id!).setData(from: newReward) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                    print("✅ Reward tillagd i Firestore: \(newReward.title)")
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteReward(rewardID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("rewards").document(rewardID).delete { error in
            if let error = error {
                print("🔴 Misslyckades att ta bort uppgiften: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Uppgift borttagen!")
                completion(.success(()))
            }
        }
    }
    
    func fetchAvailableRewards(for userID: String, completion: @escaping (Result<[Reward], Error>) -> Void) {
        db.collection("rewards").whereField("assignedTo", arrayContains: userID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let rewards = snapshot?.documents.compactMap { doc -> Reward? in
                try? doc.data(as: Reward.self)
            } ?? []
            completion(.success(rewards))
        }
    }
    
    func redeemReward(rewardID: String, userID: String, xpCost: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let rewardRef = db.collection("rewards").document(rewardID)
        let userRef = db.collection("users").document(userID)
        
        Firestore.firestore().runTransaction { transaction, errorPointer in
            let rewardSnapshot: DocumentSnapshot
            let userSnapshot: DocumentSnapshot
            
            do {
                rewardSnapshot = try transaction.getDocument(rewardRef)
                userSnapshot = try transaction.getDocument(userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            guard let rewardData = rewardSnapshot.data() else {
                print("🔴 Belöningen existerar inte!")
                return nil
            }
            
            let currentXP = userSnapshot.data()?["xp"] as? Int ?? 0
            let xpCost = rewardData["xpCost"] as? Int ?? 0
            
            if currentXP < xpCost {
                print("🔴 Inte tillräckligt med XP!")
                return nil
            }
            
            let newXP = currentXP - xpCost
            transaction.updateData(["xp": newXP], forDocument: userRef)
            transaction.updateData(["redeemedBy": FieldValue.arrayUnion([userID])], forDocument: rewardRef)
            
            return nil
        } completion: { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    func listenForRewards(for userID: String, completion: @escaping ([Reward]) -> Void) {
        let rewardsCollection = db.collection("rewards")
        
        rewardsCollection.whereField("assignedTo", arrayContains: userID).addSnapshotListener { snapshot, error in
            if let error = error {
                print("🔴 Firestore realtidsuppdatering misslyckades: \(error.localizedDescription)")
                return
            }
            
            let rewards = snapshot?.documents.compactMap { doc -> Reward? in
                try? doc.data(as: Reward.self)
            } ?? []
            
            DispatchQueue.main.async {
                completion(rewards)
            }
        }
    }
    
    func listenForCreatedRewards(for parentID: String, completion: @escaping ([Reward]) -> Void) {
        let rewardsCollection = db.collection("rewards")
        
        rewardsCollection.whereField("createdBy", isEqualTo: parentID).addSnapshotListener { snapshot, error in
            if let error = error {
                print("🔴 Firestore realtidsuppdatering misslyckades: \(error.localizedDescription)")
                return
            }
            
            let rewards = snapshot?.documents.compactMap { doc -> Reward? in
                try? doc.data(as: Reward.self)
            } ?? []
            
            DispatchQueue.main.async {
                completion(rewards)
            }
        }
    }
}
