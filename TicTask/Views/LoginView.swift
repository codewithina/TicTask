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
            ZStack {
                BackgroundView()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("TicTask")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Logga in för att fortsätta")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 16) {
                        TextField("E-post", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)

                        SecureField("Lösenord", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        authViewModel.login(email: email, password: password)
                    }) {
                        Text("Logga in")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    NavigationLink("Har du inget konto? Registrera dig", destination: RegisterView())
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
