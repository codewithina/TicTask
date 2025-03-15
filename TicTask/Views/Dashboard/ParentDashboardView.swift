//
//  ParentDashboardView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var rewardViewModel: RewardViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    NotificationSection()
                    
                    if !authViewModel.childrenUsers.isEmpty {
                        ChildrenProgressView(children: authViewModel.childrenUsers)
                    }
                    
                    TaskOverviewView()
                    
                    WeeklyTaskStatsView()
                }
                .padding()
            }
            .navigationTitle("Föräldrapanel")
            .onAppear {
                if let user = authViewModel.user, let userID = user.id {
                    notificationViewModel.startListeningForNotifications(for: userID)
                    rewardViewModel.startListeningForRewards(for: userID)
                    taskViewModel.startListeningForTasks(for: user)
                } else {
                    print("🚨 Ingen användare inloggad eller saknar ID")
                }
                
            }
            .onDisappear {
                notificationViewModel.stopListening()
            }
        }
    }
}


