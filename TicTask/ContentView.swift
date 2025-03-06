//
//  ContentView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel

    var body: some View {
        if authViewModel.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
