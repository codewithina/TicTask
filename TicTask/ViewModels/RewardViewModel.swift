//
//  RewardViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-12.
//

import SwiftUI

class RewardViewModel: ObservableObject {
    static let shared = RewardViewModel()
    
    @Published var availableRewards: [Reward] = []
    @Published var createdRewards: [Reward] = []
    @Published var errorMessage: String?
    
    func addReward(title: String, description: String, xpCost: Int, iconName: String, colorHex: String, createdBy: String, assignedTo: [String]) {
        let newReward = Reward(
            id: nil,
            title: title,
            description: description,
            xpCost: xpCost,
            createdBy: createdBy,
            assignedTo: assignedTo,
            redeemedBy: [],
            iconName: iconName,
            colorHex: colorHex
        )
        
        RewardService.shared.addReward(reward: newReward) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Reward skapad och sparad i Firestore!")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("🔴 Fel vid skapande av reward: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadRewards(for userID: String) {
        RewardService.shared.fetchAvailableRewards(for: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rewards):
                    self.availableRewards = rewards
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func redeemReward(reward: Reward, userID: String) {
        RewardService.shared.redeemReward(rewardID: reward.id ?? "", userID: userID, xpCost: reward.xpCost) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Reward inlöst!")
                    self.loadRewards(for: userID)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadCreatedRewards(for parentID: String) {
        RewardService.shared.fetchRewardsCreatedBy(parentID: parentID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rewards):
                    self.createdRewards = rewards
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func startListeningForRewards(for userID: String) {
        RewardService.shared.listenForRewards(for: userID) { rewards in
            self.availableRewards = rewards
            print("🟢 Barnets belöningar uppdaterade: \(rewards.count) rewards")
        }
    }
    
    func startListeningForCreatedRewards(for parentID: String) {
        RewardService.shared.listenForCreatedRewards(for: parentID) { rewards in
            self.createdRewards = rewards
            print("🟢 Förälderns skapade belöningar uppdaterade: \(rewards.count) rewards")
        }
    }
    
}
