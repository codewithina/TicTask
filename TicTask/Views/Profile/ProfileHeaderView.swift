//
//  ProfileHeaderView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-16.
//

import SwiftUI

struct ProfileHeaderView: View {
    let userName: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 110, height: 110)
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            
            Text(userName)
                .font(.title2)
                .bold()
                .padding(.top, 5)
        }
        .padding(.bottom, 20)
    }
}
