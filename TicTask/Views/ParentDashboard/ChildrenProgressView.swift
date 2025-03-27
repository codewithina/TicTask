//
//  ChildrenProgressView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-15.
//
import SwiftUI
import FirebaseFirestore

struct ChildrenProgressView: View {
    var children: [User]
    
    var body: some View {
            VStack {
                ForEach(children, id: \.id) { child in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text("\(child.xp ?? 0) XP")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#81C784"))
                            .frame(width: 80, height: 30, alignment: .trailing)
                    }
                }
            }
    }
}
