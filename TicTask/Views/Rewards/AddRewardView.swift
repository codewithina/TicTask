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
    @State private var selectedColor = "#FF5733" // 🔹 Standardfärg
    @State private var selectedIcon = "star.fill" // 🔹 Standardikon
    @State private var selectedChildren: [String] = []
    
    let colorOptions: [(hex: String, color: Color)] = [
        ("#D7C2D8", Color.lilac),
        ("#B3D9E1", Color.polarsky),
        ("#B1CFB7", Color.pistachio),
        ("#EFD9AA", Color.vanilla),
        ("#EFBA93", Color.apricot)
    ]
    
    let iconOptions = ["star.fill", "gift.fill", "heart.fill", "trophy.fill", "gamecontroller.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Information")) {
                    TextField("Titel", text: $title)
                    TextField("Beskrivning", text: $description)
                    Stepper("XP-kostnad: \(xpCost)", value: $xpCost, in: 5...100, step: 5)
                }
                
                Section(header: Text("Välj ikon & färg")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(iconOptions, id: \.self) { icon in
                                iconSelectionButton(icon: icon)
                            }
                        }
                    }
                    
                    HStack {
                        ForEach(colorOptions, id: \.hex) { colorOption in
                            colorSelectionButton(colorOption: colorOption)
                        }
                    }
                }
                
                Section(header: Text("Välj barn")) {
                    if authViewModel.user?.role == "parent", !authViewModel.childrenUsers.isEmpty {
                        ForEach(authViewModel.childrenUsers) { child in
                            ChildSelectionRow(child: child, selectedChildren: $selectedChildren)
                        }
                    } else {
                        Text("Du har inga barn kopplade.")
                            .foregroundColor(.gray)
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
                    .disabled(title.isEmpty || selectedChildren.isEmpty)
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
        
        showAddRewardView = false
    }
    
    private func iconSelectionButton(icon: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedIcon == icon ? Color.gray.opacity(0.3) : Color.clear)
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
        }
        .onTapGesture {
            selectedIcon = icon
        }
    }
    
    private func colorSelectionButton(colorOption: (hex: String, color: Color)) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(colorOption.color)
                .frame(width: 40, height: 40)
            if selectedColor == colorOption.hex {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .onTapGesture {
            selectedColor = colorOption.hex
        }
    }
}
