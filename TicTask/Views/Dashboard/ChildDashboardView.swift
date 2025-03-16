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
                        XPProgressView(xp: user.xp ?? 0, maxXP: 100)
                    }
                    
                    NotificationSection()
                    
                    if let task = getUpcomingTask() {
                        UpcomingTaskView(task: task)
                    }
                    
                    RewardsSummaryView(rewardCount: rewardViewModel.availableRewards.count)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                if let user = authViewModel.user, let userID = user.id {
                    notificationViewModel.startListeningForNotifications(for: userID)
                    rewardViewModel.startListeningForRewards(for: userID)
                    taskViewModel.startListeningForTasks(for: user)
                } else {
                    print("🚨 Ingen användare inloggad eller `user.id` saknas")
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
