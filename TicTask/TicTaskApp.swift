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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            //ZStack{
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(taskViewModel)
                    .environmentObject(rewardViewModel)
                    .environmentObject(notificationViewModel)
                    .onAppear {
                        rewardViewModel.notificationViewModel = notificationViewModel
                    }
               /* Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .offset(x: -100, y: -200)
                    .blur(radius: 40)
                
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .offset(x: 150, y: 200)
                    .blur(radius: 40)
                
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .offset(x: -120, y: 150)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: 220, height: 220)
                    .offset(x: 80, y: -250)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 170, height: 170)
                    .offset(x: 200, y: -100)
                    .blur(radius: 45)
                
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 140, height: 140)
                    .offset(x: -200, y: 250)
                    .blur(radius: 35)}*/
            
        }
    }
}
