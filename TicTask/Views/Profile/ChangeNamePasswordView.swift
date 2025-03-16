//
//  ChangeNamePasswordView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-16.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChangeNamePasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var newName: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text("Ändra namn")) {
                TextField(authViewModel.user?.name ?? "Nytt namn", text: $newName)                    .autocapitalization(.words)
                
                Button("Spara namnändring") {
                    updateName()
                }
                .disabled(newName.isEmpty)
            }
            
            Section(header: Text("Ändra lösenord")) {
                SecureField("Nuvarande lösenord", text: $currentPassword)
                SecureField("Nytt lösenord", text: $newPassword)
                SecureField("Bekräfta nytt lösenord", text: $confirmPassword)
                
                Button("Uppdatera lösenord") {
                    changePassword()
                }
                .disabled(newPassword.isEmpty || confirmPassword.isEmpty || currentPassword.isEmpty)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let successMessage = successMessage {
                Text("✅ \(successMessage)")
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .navigationTitle("Ändra namn & lösenord")
    }
    
    private func updateName() {
        guard let userID = authViewModel.user?.id else { return }
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        userRef.updateData(["name": newName]) { error in
            if let error = error {
                self.errorMessage = "❌ Misslyckades att uppdatera namn: \(error.localizedDescription)"
            } else {
                DispatchQueue.main.async {
                    authViewModel.user?.name = newName
                    self.newName = ""
                    self.successMessage = "Namnet har sparats!"
                }
            }
        }
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword else {
            self.errorMessage = "❌ Lösenorden matchar inte!"
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "❌ Ingen användare inloggad."
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: authViewModel.user?.email ?? "", password: currentPassword)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                self.errorMessage = "❌ Fel vid reautentisering: \(error.localizedDescription)"
                return
            }
            
            user.updatePassword(to: self.newPassword) { error in
                if let error = error {
                    self.errorMessage = "❌ Misslyckades att uppdatera lösenord: \(error.localizedDescription)"
                } else {
                    self.errorMessage = nil
                    print("✅ Lösenord uppdaterat!")
                    self.successMessage = "Lösenordet har sparats!"
                    self.currentPassword = ""
                    self.newPassword = ""
                    self.confirmPassword = ""
                }
            }
        }
    }
}
