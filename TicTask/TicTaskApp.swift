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

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(taskViewModel)
        }
    }
}
