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
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
