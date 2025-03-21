//
//  ParentListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-16.
//

import SwiftUI

struct ParentListView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Section(
            header: HStack {
                Text("Mina föräldrar")
                Spacer()
            }
        ) {
            if let parents = authViewModel.user?.parentIDs, !parents.isEmpty {
                ForEach(parents, id: \.self) { parentID in
                    VStack(alignment: .leading) {
                        Text(authViewModel.parentNames[parentID] ?? "Förälder")
                            .font(.body)
                    }
                    .padding(.vertical, 5)
                }
            } else {
                Text("Inga föräldrar kopplade.")
                    .foregroundColor(.gray)
            }
        }
    }
}
