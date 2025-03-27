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
    @State private var role = "child"
    @State private var parentIDs: [String] = []
    @State private var parentIDInput = ""
    @State private var childIDs: [String] = []
    @State private var childIDInput = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Kontoinformation")) {
                    TextField("Namn", text: $name)
                        .disableAutocorrection(true)
                    
                    TextField("E-post", text: $email)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Lösenord", text: $password)
                    
                    Picker("Välj roll", selection: $role) {
                        Text("Barn").tag("child")
                        Text("Förälder").tag("parent")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if role == "child" {
                    Section(header: Text("Lägg till förälder")) {
                        TextField("Förälderns ID", text: $parentIDInput)
                        
                        Button("Lägg till förälder") {
                            if !parentIDInput.isEmpty {
                                parentIDs.append(parentIDInput)
                                parentIDInput = ""
                            }
                        }
                        
                        ForEach(parentIDs, id: \.self) { parent in
                            HStack {
                                Text("\(parent)")
                                Spacer()
                                Button("Ta bort") {
                                    parentIDs.removeAll { $0 == parent }
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                if role == "parent" {
                    Section(header: Text("Lägg till barn")) {
                        TextField("Barnets ID", text: $childIDInput)
                        
                        Button("Lägg till barn") {
                            if !childIDInput.isEmpty {
                                childIDs.append(childIDInput)
                                childIDInput = ""
                            }
                        }
                        
                        ForEach(childIDs, id: \.self) { child in
                            HStack {
                                Text("\(child)")
                                Spacer()
                                Button("Ta bort") {
                                    childIDs.removeAll { $0 == child }
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                if let errorMessage = authViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        let selectedParentIDs = role == "child" ? parentIDs : nil
                        let selectedChildren = role == "parent" ? childIDs : nil
                        authViewModel.register(
                            email: email,
                            password: password,
                            name: name,
                            role: role,
                            parentIDs: selectedParentIDs,
                            children: selectedChildren
                        )
                    }) {
                        Text("Registrera")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Skapa konto")
        }
    }
}
