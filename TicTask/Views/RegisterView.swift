//
//  RegisterView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role = "child"  // Default: Child
    @State private var parentIDs: [String] = []  // Parent list
    @State private var parentIDInput = ""  // Input adding parents
    @State private var childIDs: [String] = []  // Child list
    @State private var childIDInput = ""  // Input adding children

    var body: some View {
        VStack {
            Text("Skapa konto")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Namn", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)

            TextField("E-post", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)

            SecureField("Lösenord", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Picker("Välj roll", selection: $role) {
                Text("Barn").tag("child")
                Text("Förälder").tag("parent")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Add parents
            if role == "child" {
                Text("Lägg till förälder (valfritt)")
                    .font(.headline)
                
                TextField("Förälderns ID", text: $parentIDInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Lägg till förälder") {
                    if !parentIDInput.isEmpty {
                        parentIDs.append(parentIDInput)
                        parentIDInput = ""
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                List(parentIDs, id: \.self) { parent in
                    HStack {
                        Text("Förälder: \(parent)")
                        Spacer()
                        Button("Ta bort") {
                            parentIDs.removeAll { $0 == parent }
                        }
                        .foregroundColor(.red)
                    }
                }
            }

            // Add children
            if role == "parent" {
                Text("Lägg till barn (valfritt)")
                    .font(.headline)
                
                TextField("Barnets ID", text: $childIDInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Lägg till barn") {
                    if !childIDInput.isEmpty {
                        childIDs.append(childIDInput)
                        childIDInput = ""
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                List(childIDs, id: \.self) { child in
                    HStack {
                        Text("Barn: \(child)")
                        Spacer()
                        Button("Ta bort") {
                            childIDs.removeAll { $0 == child }
                        }
                        .foregroundColor(.red)
                    }
                }
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                let selectedParentIDs = role == "child" ? parentIDs : nil
                let selectedChildren = role == "parent" ? childIDs : nil
                authViewModel.register(email: email, password: password, name: name, role: role, parentIDs: selectedParentIDs, children: selectedChildren)
            }) {
                Text("Registrera")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}


#Preview {
    RegisterView()
}
