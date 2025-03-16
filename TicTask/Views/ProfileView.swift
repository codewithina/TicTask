//
//  ProfileView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showAddChildPopup = false
    @State private var showLogoutConfirmation = false
    @State private var childID = ""
    @State private var errorMessage: String?
    
    var isParent: Bool {
        authViewModel.user?.role == "parent"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ProfileHeaderView(userName: authViewModel.user?.name ?? "Okänt namn")
                
                Form {
                    XPSectionView(xp: authViewModel.user?.xp ?? 0)
                    
                    if isParent {
                        ChildrenListView(authViewModel: authViewModel, showAddChildPopup: $showAddChildPopup)
                    } else {
                        ParentListView(authViewModel: authViewModel)
                    }
                    
                    LogoutButtonView(showLogoutConfirmation: $showLogoutConfirmation)
                }
                
                Spacer()
            }
            .alert("Lägg till barn via ID", isPresented: $showAddChildPopup, actions: {
                TextField("Barnets ID", text: $childID)
                Button("Lägg till") {
                    authViewModel.addExistingChildByID(childID: childID) { result in
                        switch result {
                        case .success():
                            print("✅ Barn tillagt!")
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                    childID = ""
                    showAddChildPopup = false
                }
                Button("Avbryt", role: .cancel) {}
            }, message: {
                Text("Skriv in barnets unika ID för att koppla det till din profil.")
            })
            
            .alert("Logga ut", isPresented: $showLogoutConfirmation, actions: {
                Button("Ja, logga ut", role: .destructive) {
                    authViewModel.logout { result in
                        switch result {
                        case .success():
                            print("✅ Användaren loggades ut.")
                        case .failure(let error):
                            print("❌ Misslyckades att logga ut: \(error.localizedDescription)")
                        }
                    }
                }
                Button("Avbryt", role: .cancel) {}
            }, message: {
                Text("Är du säker på att du vill logga ut?")
            })
        }
    }
}
