//
//  ProfileView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                                    // Add children, create function
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
                                    VStack(alignment: .leading) {
                                        Text(child.name)
                                            .font(.body)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    } else {
                        Section(
                            header: HStack {
                                Text("Mina föräldrar")
                                Spacer()
                                Button(action: {
                                    // Add parent, create function
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                }
                            }
                        ) {
                            if let parents = authViewModel.user?.parentIDs, !parents.isEmpty {
                                ForEach(parents, id: \.self) { parentID in
                                    VStack(alignment: .leading) {
                                        Text(authViewModel.parentNames[parentID] ?? "Förälder")
                                            .font(.body)
                                    }
                                    .padding(.vertical, 5)
                                }
                            } else {
                                Text("Inga föräldrar kopplade.")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
