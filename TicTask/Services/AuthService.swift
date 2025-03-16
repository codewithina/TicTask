//
//  AuthService.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//

import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // Register new user and send to Firestore
    func registerUser(email: String, password: String, name: String, role: String, parentIDs: [String]?, children: [String]?, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let userID = result?.user.uid else { return }
            
            var userData: [String: Any] = [
                "name": name,
                "email": email,
                "role": role
            ]
            
            if role == "child" {
                userData["xp"] = 0
                userData["parentIDs"] = parentIDs ?? []
            } else if role == "parent" {
                userData["children"] = children ?? []
            }
            
            self.db.collection("users").document(userID).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let user = User(id: userID, name: name, email: email, role: role, xp: role == "child" ? 0 : nil,  parentIDs: parentIDs ?? [], children: children ?? [])
                    
                    let notificationRef = self.db.collection("users").document(userID).collection("notifications")
                    
                    let welcomeNotification: [String: Any] = [
                        "message": "Välkommen till TicTask!",
                        "timestamp": Timestamp(date: Date())
                    ]
                    
                    notificationRef.addDocument(data: welcomeNotification) { error in
                        if let error = error {
                            print("🔴 Misslyckades att skapa notiscollection: \(error.localizedDescription)")
                        } else {
                            print("✅ Notiscollection skapad för \(userID)")
                        }
                    }
                    
                    let batch = self.db.batch()
                    
                    // If child adds one or more parents during registration → Update parents `children`
                    if let parentIDs = parentIDs {
                        for parentID in parentIDs {
                            let parentRef = self.db.collection("users").document(parentID)
                            batch.updateData(["children": FieldValue.arrayUnion([userID])], forDocument: parentRef)
                            print("🟢 Förälderns barnlista uppdaterad i Firestore: \(parentID)")
                        }
                    }
                    
                    // If parent adds one or more children during registration → Update child's `parentIDs`
                    if let children = children {
                        for childID in children {
                            let childRef = self.db.collection("users").document(childID)
                            batch.updateData(["parentIDs": FieldValue.arrayUnion([userID])], forDocument: childRef)
                            print("🟢 Barnets föräldralista uppdaterad i Firestore: \(childID)")
                        }
                    }
                    
                    batch.commit { error in
                        if let error = error {
                            print("🔴 Firestore batch-uppdatering misslyckades: \(error.localizedDescription)")
                            completion(.failure(error))
                        } else {
                            print("✅ Firestore batch-uppdatering lyckades!")
                            completion(.success(user))
                        }
                    }
                }
            }
        }
    }
    
    
    // Login user and fetch Firestore-data
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let firebaseUser = result?.user else { return }
            
            // Fetch user data from Firestore
            self.db.collection("users").document(firebaseUser.uid).getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = snapshot?.data() {
                    let user = User(
                        id: firebaseUser.uid,
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        role: data["role"] as? String ?? "",
                        xp: data["xp"] as? Int ?? 0,
                        parentIDs: data["parentIDs"] as? [String] ?? [],
                        children: data["children"] as? [String] ?? []
                    )
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ingen användardata hittades i Firestore."])))
                }
            }
        }
    }
    
    // Logout user
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}


