//
//  AuthViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//
import SwiftUI
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User?  // Save user object
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var childrenNames: [String: String] = [:]
    @Published var parentNames: [String: String] = [:]
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
                        self.fetchChildrenNames()
                    }
                    
                    if user.role == "child" {
                        self.fetchParentNames()
                    }
                    
                    if user.role == "parent" || user.role == "child" {
                        print("🟢 Startar Firestore realtidslyssnare för \(user.name)")
                        TaskViewModel.shared.startListeningForTasks(for: user)
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
    
    func fetchChildrenNames() {
        guard let children = user?.children, !children.isEmpty else { return }

        let group = DispatchGroup()

        for childID in children {
            group.enter()

            Firestore.firestore().collection("users").document(childID).getDocument { snapshot, error in
                if let data = snapshot?.data(), let name = data["name"] as? String {
                    DispatchQueue.main.async {
                        self.childrenNames[childID] = name
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            print("✅ Alla barnens namn har hämtats: \(self.childrenNames)")
        }
    }
    
    
    func fetchParentNames() {
            guard let parents = user?.parentIDs, !parents.isEmpty else { return }

            let group = DispatchGroup()

            for parentID in parents {
                group.enter()
                Firestore.firestore().collection("users").document(parentID).getDocument { snapshot, error in
                    if let data = snapshot?.data(), let name = data["name"] as? String {
                        DispatchQueue.main.async {
                            self.parentNames[parentID] = name
                        }
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("✅ Alla föräldrars namn har hämtats: \(self.parentNames)")
            }
        }
}



