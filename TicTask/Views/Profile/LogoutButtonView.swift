//
//  LogoutButtonView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-16.
//

import SwiftUI

struct LogoutButtonView: View {
    @Binding var showLogoutConfirmation: Bool
    
    var body: some View {
        Section {
            Button(role: .destructive) {
                showLogoutConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Logga ut")
                        .bold()
                    Spacer()
                }
            }
        }
    }
}
