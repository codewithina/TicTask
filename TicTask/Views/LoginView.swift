//
//  LoginView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("TicTask")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("E-post", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)

                SecureField("Lösenord", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button("Logga in") {
                    authViewModel.login(email: email, password: password)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink("Registrera nytt konto", destination: RegisterView())
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
}
