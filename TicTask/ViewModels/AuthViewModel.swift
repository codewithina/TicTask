//
//  AuthViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User?  // Save user object
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    private let authService = AuthService.shared
    private let taskViewModel = TaskViewModel.shared

    // Register and auto login
    func register(email: String, password: String, name: String, role: String, parentIDs: [String]?, children: [String]?) {
        print("🟡 Försöker registrera användare: \(email)")
        self.errorMessage = nil

        authService.registerUser(email: email, password: password, name: name, role: role, parentIDs: parentIDs, children: children) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Registrering lyckades!")
                    self.user = user
                    self.isAuthenticated = true
                case .failure(let error):
                    print("🔴 Registrering misslyckades: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
  
    // Login and fetch user info
    func login(email: String, password: String) {
        print("🟡 Försöker logga in: \(email)")
        self.errorMessage = nil

        authService.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Inloggning lyckades! Roll: \(user.role)")
                    self.user = user
                    self.isAuthenticated = true
                    
                    if user.role == "parent" {
                        TaskViewModel.shared.fetchChildrenTasks(for: user)
                    }
                    
                case .failure(let error):
                    print("🔴 Inloggning misslyckades: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Logout user
    func logout() {
        authService.logout { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🔴 Utloggad!")
                    self.user = nil
                    self.isAuthenticated = false
                case .failure(let error):
                    print("❌ Utloggning misslyckades: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}



