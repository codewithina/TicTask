//
//  TicTaskApp.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-25.
//

import SwiftUI
import Firebase

@main
struct TicTaskApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var rewardViewModel = RewardViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @StateObject private  var xpViewModel = XPViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(taskViewModel)
                .environmentObject(rewardViewModel)
                .environmentObject(notificationViewModel)
                .environmentObject(xpViewModel)
                .onAppear {
                    rewardViewModel.notificationViewModel = notificationViewModel
                    rewardViewModel.authViewModel = authViewModel
                    taskViewModel.notificationViewModel = notificationViewModel
                    taskViewModel.authViewModel = authViewModel
                    authViewModel.taskViewModel = taskViewModel
                    authViewModel.xpViewModel = xpViewModel
                }
        }
    }
}
