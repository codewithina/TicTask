//
//  ChildrenListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-16.
//

import SwiftUI

struct ChildrenListView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var showAddChildPopup: Bool
    
    var body: some View {
        Section(
            header: HStack {
                Text("Mina barn")
                Spacer()
                Button(action: {
                    showAddChildPopup = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        ) {
            if authViewModel.childrenUsers.isEmpty {
                Text("Inga barn kopplade.")
                    .foregroundColor(.gray)
            } else {
                ForEach(authViewModel.childrenUsers, id: \.id) { child in
                    HStack {
                        Text(child.name)
                            .font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let childID = child.id {
                                authViewModel.removeChild(childID: childID)
                            }
                        } label: {
                            Label("Ta bort", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}
