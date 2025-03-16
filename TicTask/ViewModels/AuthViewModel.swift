//
//  AuthViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//
import SwiftUI
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var childrenNames: [String: String] = [:]
    @Published var parentNames: [String: String] = [:]
    @Published var childrenUsers: [User] = []
    private let authService = AuthService.shared
    private let taskViewModel = TaskViewModel.shared
    
    private let db = Firestore.firestore()
    private var childrenListeners: [ListenerRegistration] = []
    private var userListener: ListenerRegistration?
    
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
                    
                    if user.role == "parent" {
                        self.loadAndListenToChildren(for: user)
                    }
                    
                    if user.role == "child" {
                        self.fetchParentNames()
                    }
                    
                    if user.role == "parent" || user.role == "child" {
                        print("🟢 Startar Firestore realtidslyssnare för \(user.name)")
                        self.startListeningForUserChanges()
                        TaskViewModel.shared.startListeningForTasks(for: user)
                    }
                    
                case .failure(let error):
                    print("🔴 Registrering misslyckades: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
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
                        self.loadAndListenToChildren(for: user)
                    }
                    
                    if user.role == "child" {
                        self.fetchParentNames()
                    }
                    
                    if user.role == "parent" || user.role == "child" {
                        print("🟢 Startar Firestore realtidslyssnare för \(user.name)")
                        self.startListeningForUserChanges()
                        TaskViewModel.shared.startListeningForTasks(for: user)
                    }
                    
                case .failure(let error):
                    print("🔴 Inloggning misslyckades: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        authService.logout { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🔴 Utloggad!")
                    self.stopListeningForChildrenUpdates()
                    self.userListener?.remove()
                    self.userListener = nil
                    self.user = nil
                    self.childrenUsers = []
                    self.isAuthenticated = false
                case .failure(let error):
                    print("❌ Utloggning misslyckades: \(error.localizedDescription)")
                    self.errorMessage = "Misslyckades att logga ut: \(error.localizedDescription)"
                }
            }
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
    
    func startListeningForUserChanges() {
        guard let currentUser = user, let userID = user?.id else {
            print("🚨 Ingen användare inloggad, kan inte starta lyssnaren.")
            return
        }

        print("📡 Startar realtidslyssnare för den inloggade användaren.")

        userListener = db.collection("users").document(userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }

                let newXP = data["xp"] as? Int ?? 0

                DispatchQueue.main.async {
                    self.user = User(
                        id: currentUser.id,
                        name: currentUser.name,
                        email: currentUser.email,
                        role: currentUser.role,
                        xp: newXP,  // 🟢 Uppdaterad XP
                        parentIDs: currentUser.parentIDs,
                        children: currentUser.children
                    )

                    print("📢 Uppdaterad XP: \(self.user?.xp ?? 0)")
                }
            }
    }
    
    func loadAndListenToChildren(for user: User) {
        stopListeningForChildrenUpdates()
        
        let childrenIDs = user.children ?? []
        
        guard !childrenIDs.isEmpty else {
            print("🚨 Inga barn att lyssna på.")
            return
        }
        
        childrenUsers.removeAll()
        
        for childID in childrenIDs {
            let listener = db.collection("users").document(childID)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("🔴 Fel vid lyssning på barn \(childID): \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = snapshot?.data(), !data.isEmpty else {
                        print("⚠️ Ingen data hittades för barn \(childID)")
                        return
                    }
                    
                    print("📢 Hämtade data för \(childID): \(data)")
                    
                    guard let childID = snapshot?.documentID else {
                        print("❌ Dokument-ID saknas för \(childID)")
                        return
                    }
                    
                    let child = User(
                        id: childID,
                        name: data["name"] as? String ?? "Okänt namn",
                        email: data["email"] as? String ?? "Ingen e-post",
                        role: data["role"] as? String ?? "unknown",
                        xp: data["xp"] as? Int ?? 0,
                        parentIDs: data["parentIDs"] as? [String] ?? [],
                        children: data["children"] as? [String] ?? []
                    )
                    
                    DispatchQueue.main.async {
                        if let index = self.childrenUsers.firstIndex(where: { $0.id == child.id }) {
                            self.childrenUsers[index] = child
                        } else {
                            self.childrenUsers.append(child)
                        }
                        print("✅ Uppdaterad data för \(child.name), XP: \(child.xp ?? 0)")
                    }
                }
            
            childrenListeners.append(listener)
        }
    }
    
    
    func stopListeningForChildrenUpdates() {
        for listener in childrenListeners {
            listener.remove()
        }
        childrenListeners.removeAll()
        childrenUsers.removeAll()
    }
    
}



