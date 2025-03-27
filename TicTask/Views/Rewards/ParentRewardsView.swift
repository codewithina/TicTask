//
//  ParentRewardsView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ParentRewardsView: View {
    @EnvironmentObject var rewardViewModel: RewardViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddRewardView = false

    var body: some View {
        NavigationStack {
            VStack {
                if rewardViewModel.createdRewards.isEmpty {
                    Text("Du har inte skapat några belöningar ännu.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(rewardViewModel.createdRewards) { reward in
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
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Skapade Belöningar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddRewardView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddRewardView) {
                AddRewardView(showAddRewardView: $showAddRewardView)
            }
            .onAppear {
                if let parentID = authViewModel.user?.id {
                    rewardViewModel.startListeningForCreatedRewards(for: parentID)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let reward = rewardViewModel.createdRewards[index]
            rewardViewModel.deleteReward(reward: reward)
        }
    }
}

#Preview {
    ParentRewardsView()
}
