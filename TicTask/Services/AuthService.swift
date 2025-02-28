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
    func registerUser(email: String, password: String, name: String, role: String, parentID: String?, completion: @escaping (Result<User, Error>) -> Void) {
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

            if role == "child", let parentID = parentID {
                userData["parentID"] = parentID
            } else if role == "parent" {
                userData["children"] = []
            }

            // Save user in Firestore
            self.db.collection("users").document(userID).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let user = User(id: userID, name: name, email: email, role: role, parentID: parentID, children: [])
                    completion(.success(user))
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
                        parentID: data["parentID"] as? String ?? "",
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


