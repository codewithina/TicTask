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
        SectionBox(title: "Mina barn") {
            VStack {
                ForEach(children, id: \.id) { child in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.headline)
                        }
                        Spacer()
                        Text("\(child.xp ?? 0) XP")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 30, alignment: .trailing)
                    }
                    .padding()
                }
            }
        }
    }
}
