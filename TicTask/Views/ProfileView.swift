//
//  ProfileView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var user: User? {
        authViewModel.user
    }
    
    var isParent: Bool {
        user?.role == "parent"
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Profile pic and name
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

                    Text(user?.name ?? "Okänt namn")
                        .font(.title2)
                        .bold()
                        .padding(.top, 5)
                }
                .padding(.bottom, 20)

                Form {
                    // XP-section
                    Section(header: Text("XP & Framsteg")) {
                        Text("\(user?.xp ?? 0) XP")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Family
                    if isParent {
                        Section(
                            header: HStack {
                                Text("Mina barn")
                                Spacer()
                                Button(action: {
                                    // Handle add child
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        ) {
                            if let children = user?.children, !children.isEmpty {
                                ForEach(children, id: \.self) { childID in
                                    VStack(alignment: .leading) {
                                        Text(authViewModel.childrenNames[childID] ?? "Barn")
                                            .font(.body)
                                    }
                                    .padding(.vertical, 5)
                                }
                            } else {
                                Text("Inga barn kopplade.")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Section(
                            header: HStack {
                                Text("Mina föräldrar")
                                Spacer()
                                Button(action: {
                                    // HHandle add parent
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                }
                            }
                        ) {
                            if let parents = user?.parentIDs, !parents.isEmpty {
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
