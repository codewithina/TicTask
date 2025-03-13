//
//  AddTaskView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showAddTaskView: Bool
    
    @State private var title = ""
    @State private var description = ""
    @State private var deadline = Date()
    @State private var xpReward = 10
    @State private var selectedChild = ""
    // @State private var selectedChildren: [String] = []
    @State private var selectedIcon = "pencil" // Default
    @State private var selectedColor = "#FF5733" // Default
    
    let colorOptions: [(hex: String, color: Color)] = [
        ("#D7C2D8", Color.lilac),
        ("#B3D9E1", Color.polarsky),
        ("#B1CFB7", Color.pistachio),
        ("#EFD9AA", Color.vanilla),
        ("#EFBA93", Color.apricot)
    ]
    
    let iconOptions = ["pencil", "book", "checkmark.circle", "calendar", "clock"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Uppgiftsinformation")) {
                    TextField("Titel", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Beskrivning")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 5)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .padding(.vertical, 5)
                    }
                    
                    
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    Stepper("XP Belöning: \(xpReward)", value: $xpReward, in: 5...50, step: 5)
                }
                
                Section(header: Text("Välj ikon & färg")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(iconOptions, id: \.self) { icon in
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
                        }
                    }
                    .padding(.vertical, 5)
                    
                    HStack {
                        ForEach(colorOptions, id: \.hex) { colorOption in
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
                    .padding(.vertical, 5)
                }
                
                if let user = authViewModel.user, user.role == "parent", let children = user.children, !children.isEmpty {
                    Section(header: Text("Välj barn")) {
                        ForEach(children, id: \.self) { childID in
                            HStack {
                                Text(authViewModel.childrenNames[childID] ?? "Okänt namn")
                                Spacer()
                                if selectedChild == childID {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedChild = childID
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Lägg till läxa")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") {
                        showAddTaskView = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Spara") {
                        saveTask()
                    }
                    .disabled(authViewModel.user?.role == "parent" && selectedChild.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        guard let user = authViewModel.user else { return }
        
        if user.role == "child" {
            taskViewModel.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: user.id, assignedTo: user.id, iconName: selectedIcon, colorHex: selectedColor)
        } else if user.role == "parent", !selectedChild.isEmpty {
            taskViewModel.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: user.id, assignedTo: selectedChild, iconName: selectedIcon, colorHex: selectedColor)
        }
        showAddTaskView = false
    }
}

#Preview {
    AddTaskView(showAddTaskView: .constant(true))
        .environmentObject(TaskViewModel.shared)
        .environmentObject(AuthViewModel())
}


