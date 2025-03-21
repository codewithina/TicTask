//
//  ChildDashboardView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ChildDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var rewardViewModel: RewardViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = authViewModel.user {
                        XPProgressView(allTimeXP: user.totalXP ?? 0, spendableXP: user.xp ?? 0, maxXPPerLevel: 1000)
                            .padding(.bottom, 10)
                    }
                    
                    NotificationSection(title: "Notiser", icon: "bell", color: "#FFC107")
                    
                    if let task = getUpcomingTask() {
                        DashboardCard(title: "Nästa Uppgift", icon: "calendar", color: "#2196F3") {
                            UpcomingTaskView(task: task)
                        }
                    }
                    
                    DashboardCard(title: "Belöningar", icon: "gift", color: "#4CAF50") {
                        RewardsSummaryView(rewardCount: rewardViewModel.availableRewards.count)
                    }
                }
                .padding()
            }
            
           /* .navigationBarItems(trailing: HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                
                Text("\(authViewModel.user?.xp ?? 0) XP")
                    .font(.headline)
            })*/
            
            .onAppear {
                if let user = authViewModel.user, let userID = user.id {
                    notificationViewModel.startListeningForNotifications(for: userID)
                    rewardViewModel.startListeningForRewards(for: userID)
                    taskViewModel.startListeningForTasks(for: user)
                }
            }
            .onDisappear {
                notificationViewModel.stopListening()
                
            }
        }
    }
    
    private func getUpcomingTask() -> Task? {
        taskViewModel.tasks.sorted {
            ($0.deadline ?? Date.distantFuture) < ($1.deadline ?? Date.distantFuture)
        }.first
    }
}

