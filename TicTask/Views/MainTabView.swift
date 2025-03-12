//
//  MainTabView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if let user = authViewModel.user {
            TabView {
                if user.role == "child" {
                    ChildDashboardView()
                        .tabItem {
                            Label("Hem", systemImage: "house.fill")
                        }
                    
                    TaskListView()
                        .tabItem {
                            Label("Läxor", systemImage: "list.bullet")
                        }
                    
                    RewardsView()
                        .tabItem {
                            Label("Belöningar", systemImage: "gift.fill")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profil", systemImage: "person.fill")
                        }
                } else if user.role == "parent" {
                    ParentDashboardView()
                        .tabItem {
                            Label("Hem", systemImage: "house.fill")
                        }
                    
                    TaskListView()
                        .tabItem {
                            Label("Läxor", systemImage: "list.bullet")
                        }
                    
                    ParentRewardsView()
                        .tabItem {
                            Label("Mina Barn", systemImage: "gift.fill")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profil", systemImage: "person.fill")
                        }
                }
            }
        } else {
            LoginView()
        }
    }
}
