//
//  AddRewardView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-12.
//

import SwiftUI

struct AddRewardView: View {
    @EnvironmentObject var rewardViewModel: RewardViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showAddRewardView: Bool
    
    @State private var title = ""
    @State private var description = ""
    @State private var xpCost = 10
    @State private var selectedColor = "#FF5733" // Default
    @State private var selectedIcon = "star" // Default
    @State private var selectedChildren: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Information")) {
                    TextField("Titel", text: $title)
                    TextField("Beskrivning", text: $description)
                    Stepper("XP-kostnad: \(xpCost)", value: $xpCost, in: 5...100, step: 5)
                }
                
                Section(header: Text("Välj ikon & färg")) {
                    TextField("Ikon (SF Symbol)", text: $selectedIcon)
                    TextField("Färg (Hex)", text: $selectedColor)
                }
                
                Section(header: Text("Välj barn")) {
                    if let children = authViewModel.user?.children, !children.isEmpty {
                        ForEach(children, id: \.self) { childID in
                            HStack {
                                Text(authViewModel.childrenNames[childID] ?? "Okänt namn")
                                Spacer()
                                if selectedChildren.contains(childID) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .onTapGesture {
                                if selectedChildren.contains(childID) {
                                    selectedChildren.removeAll { $0 == childID }
                                } else {
                                    selectedChildren.append(childID)
                                }
                            }
                        }
                    } else {
                        Text("Du har inga barn kopplade.")
                    }
                }
            }
            .navigationTitle("Skapa ny belöning")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") {
                        showAddRewardView = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Spara") {
                        saveReward()
                    }
                }
            }
        }
    }
    
    private func saveReward() {
        guard let parentID = authViewModel.user?.id else { return }
        
        rewardViewModel.addReward(
            title: title,
            description: description,
            xpCost: xpCost,
            iconName: selectedIcon,
            colorHex: selectedColor,
            createdBy: parentID,
            assignedTo: selectedChildren
        )
        
        showAddRewardView = false  // Closing view
    }
}
