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
    @Published var errorMessage: String?

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
}
