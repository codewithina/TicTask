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
                    XPProgressView(userXP: authViewModel.user?.xp ?? 0, maxXP: 100)
                    
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
                if let user = authViewModel.user {
                    notificationViewModel.startListeningForNotifications(for: user.id)
                    rewardViewModel.startListeningForRewards(for: user.id)
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


#Preview {
    ChildDashboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(TaskViewModel.shared)
        .environmentObject(RewardViewModel.shared)
}
