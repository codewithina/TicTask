//
//  ContentView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isAuthenticated {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
