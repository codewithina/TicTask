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
    @EnvironmentObject var xpViewModel: XPViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    NotificationSection(title: "Notiser", icon: "bell", color: "#FFC107")
                    
                    DashboardCard(title: "Poäng att handla för", icon: "person.crop.circle", color: "#4CAF50") {
                        if !authViewModel.childrenUsers.isEmpty {
                            ChildrenProgressView(children: authViewModel.childrenUsers)
                        }
                    }
                    
                    DashboardCard(title: "Veckans uppgifter", icon: "chart.bar.xaxis", color: "#3F51B5") {
                        TaskProgressPerChildView()
                    }
                    
                    DashboardCard(title: "Insamlad XP", icon: "chart.line.uptrend.xyaxis", color: "#3F51B5") {
                        ChildrenXPPerDayChartView()
                    }

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


