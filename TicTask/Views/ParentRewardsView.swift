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
        NavigationView {
            VStack {
                if rewardViewModel.createdRewards.isEmpty {
                    Text("Du har inte skapat några belöningar ännu.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(rewardViewModel.createdRewards) { reward in
                        HStack {
                            Image(systemName: reward.iconName)
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
                        }
                        .padding()
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
}


#Preview {
    ParentRewardsView()
}
