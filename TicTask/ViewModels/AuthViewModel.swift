//
//  AuthViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//
import SwiftUI
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    var taskViewModel: TaskViewModel?
    var xpViewModel: XPViewModel?
    
    private let authService = AuthService.shared
    private let db = Firestore.firestore()
    private var childrenListeners: [ListenerRegistration] = []
    private var userListener: ListenerRegistration?
    private var parentListeners: [ListenerRegistration] = []
    
    @Published var user: User?
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var childrenNames: [String: String] = [:]
    @Published var parentNames: [String: String] = [:]
    @Published var childrenUsers: [User] = []
    
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
                        self.loadAndListenToParents(for: user)
                    }
                    
                    if user.role == "parent" || user.role == "child" {
                        print("🟢 Startar Firestore realtidslyssnare för \(user.name)")
                        self.startListeningForUserChanges()
                        self.taskViewModel?.startListeningForTasks(for: user)
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
                        self.loadAndListenToParents(for: user)
                    }
                    
                    if user.role == "parent" || user.role == "child" {
                        print("🟢 Startar Firestore realtidslyssnare för \(user.name)")
                        self.startListeningForUserChanges()
                        self.taskViewModel?.startListeningForTasks(for: user)
                    }
                    
                case .failure(let error):
                    print("🔴 Inloggning misslyckades: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
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
                    completion(.success(()))
                case .failure(let error):
                    print("❌ Utloggning misslyckades: \(error.localizedDescription)")
                    self.errorMessage = "Misslyckades att logga ut: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func loadAndListenToParents(for user: User) {
        stopListeningForParentUpdates()
        
        guard let parentIDs = user.parentIDs, !parentIDs.isEmpty else {
            print("🚨 Inga föräldrar att lyssna på.")
            return
        }
        
        parentNames.removeAll()
        
        for parentID in parentIDs {
            let listener = db.collection("users").document(parentID)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("🔴 Fel vid lyssning på förälder \(parentID): \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = snapshot?.data(), !data.isEmpty else {
                        print("⚠️ Ingen data hittades för förälder \(parentID)")
                        return
                    }
                    
                    print("📢 Hämtade data för \(parentID): \(data)")
                    
                    if let name = data["name"] as? String {
                        DispatchQueue.main.async {
                            self.parentNames[parentID] = name
                            print("✅ Uppdaterat föräldernamn för \(parentID): \(name)")
                        }
                    }
                }
            
            parentListeners.append(listener)
        }
    }
    func stopListeningForParentUpdates() {
        for listener in parentListeners {
            listener.remove()
        }
        parentListeners.removeAll()
        print("🛑 Stoppade alla föräldralyssnare.")
    }
    
    func startListeningForUserChanges() {
        guard let userID = user?.id else {
            print("🚨 Ingen användare inloggad, kan inte starta lyssnaren.")
            return
        }

        print("📡 Startar realtidslyssnare för den inloggade användaren.")

        userListener = db.collection("users").document(userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }

                let updatedUser = User(
                    id: userID,
                    name: data["name"] as? String ?? "Okänt namn",
                    email: data["email"] as? String ?? "Ingen e-post",
                    role: data["role"] as? String ?? "unknown",
                    xp: data["xp"] as? Int ?? 0,
                    totalXP: data["totalXP"] as? Int ?? 0,
                    parentIDs: data["parentIDs"] as? [String] ?? [],
                    children: data["children"] as? [String] ?? []
                )

                DispatchQueue.main.async {
                    self.user = updatedUser
                    print("📢 Användarens data uppdaterad: \(self.user?.name ?? "Okänt namn")")
                }
            }
    }

    
    func addExistingChildByID(childID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let parentID = user?.id else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ingen inloggad förälder."])))
            return
        }

        let childRef = db.collection("users").document(childID)
        let parentRef = db.collection("users").document(parentID)

        childRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
           // guard let data = document?.data(), let childName = data["name"] as? String
            guard let data = document?.data(), data["name"] as? String != nil else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Barn-ID hittades inte."])))
                return
            }


            let batch = self.db.batch()
            
            batch.updateData(["parentIDs": FieldValue.arrayUnion([parentID])], forDocument: childRef)
            batch.updateData(["children": FieldValue.arrayUnion([childID])], forDocument: parentRef)

            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("✅ Barn kopplades till förälder i Firestore!")
                    completion(.success(()))
                }
            }
        }
    }
    
    func removeChild(childID: String) {
        guard let parentID = user?.id else { return }

        let childRef = db.collection("users").document(childID)
        let parentRef = db.collection("users").document(parentID)

        let batch = db.batch()

        batch.updateData(["parentIDs": FieldValue.arrayRemove([parentID])], forDocument: childRef)
        batch.updateData(["children": FieldValue.arrayRemove([childID])], forDocument: parentRef)

        batch.commit { error in
            if let error = error {
                print("❌ Misslyckades att ta bort barnet: \(error.localizedDescription)")
            } else {
                print("✅ Barn borttaget!")
                self.childrenUsers.removeAll { $0.id == childID }
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
                        totalXP: data["totalXP"] as? Int ?? 0,
                        parentIDs: data["parentIDs"] as? [String] ?? [],
                        children: data["children"] as? [String] ?? []
                    )
                    
                    DispatchQueue.main.async {
                        if let index = self.childrenUsers.firstIndex(where: { $0.id == child.id }) {
                            self.childrenUsers[index] = child
                        } else {
                            self.childrenUsers.append(child)
                        }
                        print("✅ Uppdaterad data för \(child.name), XP: \(child.xp ?? 0), total XP: \(child.totalXP ?? 0)")
                        self.xpViewModel?.startListeningForXPPerDay(for: self.childrenUsers)
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



