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
    
    @State private var showConfirmation = false
    @State private var selectedReward: Reward?

    var body: some View {
        NavigationStack {
            VStack {
                if rewardViewModel.availableRewards.isEmpty {
                    Text("Inga rewards tillgängliga")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(rewardViewModel.availableRewards) { reward in
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: reward.colorHex).opacity(0.2))
                                    .frame(width: 50, height: 50)

                                Image(systemName: reward.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(hex: reward.colorHex))
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(reward.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(reward.description)
                                    .font(.subheadline)
                                    .lineLimit(2)

                                Text("XP: \(reward.xpCost)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            let canAfford = (authViewModel.user?.xp ?? 0) >= reward.xpCost

                            Button(action: {
                                selectedReward = reward
                                showConfirmation = true
                            }) {
                                Text("Köp")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(canAfford ? Color.green : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(!canAfford)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Belöningar")
            .onAppear {
                if let userID = authViewModel.user?.id {
                    rewardViewModel.startListeningForRewards(for: userID)
                }
            }
            .confirmationDialog("Är du säker att du vill köpa denna belöning?",
                                isPresented: $showConfirmation,
                                titleVisibility: .visible) {
                Button("Ja, köp", role: .destructive) {
                    if let userID = authViewModel.user?.id, let reward = selectedReward {
                        rewardViewModel.redeemReward(reward: reward, userID: userID)
                    }
                }
                Button("Avbryt", role: .cancel) {}
            } message: {
                if let reward = selectedReward {
                    Text("\(reward.title) kostar \(reward.xpCost) XP.")
                }
            }
        }
    }
}



#Preview {
    RewardsView()
}
