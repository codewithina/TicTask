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
    @State private var childID = ""
    @State private var errorMessage: String?
    
    var isParent: Bool {
        authViewModel.user?.role == "parent"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 110, height: 110)
                        
                        Image(systemName: "person.circle.fill") // Placeholder avatar
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                    
                    Text(authViewModel.user?.name ?? "Okänt namn")
                        .font(.title2)
                        .bold()
                        .padding(.top, 5)
                }
                .padding(.bottom, 20)
                
                // XP-sektion
                Form {
                    Section {
                        Text("\(authViewModel.user?.xp ?? 0) XP")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if isParent {
                        Section(
                            header: HStack {
                                Text("Mina barn")
                                Spacer()
                                Button(action: {
                                    showAddChildPopup = true
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                }
                            }
                        ) {
                            if authViewModel.childrenUsers.isEmpty {
                                Text("Inga barn kopplade.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(authViewModel.childrenUsers, id: \.id) { child in
                                    HStack {
                                        Text(child.name)
                                            .font(.body)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .alert("Lägg till barn via ID", isPresented: $showAddChildPopup) {
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
            } message: {
                Text("Skriv in barnets unika ID för att koppla det till din profil.")
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}



#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
