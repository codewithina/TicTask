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
    @State private var parentID = ""

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

            if role == "child" {
                TextField("Förälderns ID (valfritt)", text: $parentID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                let parentIDValue = role == "child" ? parentID : nil
                authViewModel.register(email: email, password: password, name: name, role: role, parentID: parentIDValue)
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
