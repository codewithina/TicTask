//
//  RewardsView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var rewardViewModel: RewardViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            if rewardViewModel.availableRewards.isEmpty {
                Text("Inga rewards tillgängliga")
                    .foregroundColor(.gray)
            } else {
                List(rewardViewModel.availableRewards) { reward in
                    HStack {
                        Image(systemName: reward.iconName) // SF Symbol
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(hex: reward.colorHex))
                        
                        VStack(alignment: .leading) {
                            Text(reward.title)
                                .font(.headline)
                            Text(reward.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("XP: \(reward.xpCost)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button(action: {
                            if let userID = authViewModel.user?.id {
                                rewardViewModel.redeemReward(reward: reward, userID: userID)
                            }
                        }) {
                            Text("Köp")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            if let userID = authViewModel.user?.id {
                rewardViewModel.startListeningForRewards(for: userID)
            }
        }
    }
}

#Preview {
    RewardsView()
}
