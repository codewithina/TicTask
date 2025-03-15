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
    @State private var selectedChild: User? // 🔥 Nu håller vi ett helt `User`-objekt istället för bara en sträng
    @State private var selectedIcon = "pencil"
    @State private var selectedColor = "#FF5733"
    
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
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    
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
                }
                
                if authViewModel.user?.role == "parent", !authViewModel.childrenUsers.isEmpty {
                    Section(header: Text("Välj barn")) {
                        ForEach(authViewModel.childrenUsers, id: \.id) { child in
                            HStack {
                                Text(child.name)
                                Spacer()
                                if selectedChild?.id == child.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedChild = child
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
                    .disabled(authViewModel.user?.role == "parent" && selectedChild == nil)
                }
            }
        }
    }
    
    private func saveTask() {
        guard let user = authViewModel.user, let userID = user.id else {
            print("🚨 Ingen användare inloggad eller `user.id` saknas")
            return
        }

        if user.role == "child" {
            taskViewModel.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: userID, assignedTo: userID, iconName: selectedIcon, colorHex: selectedColor)
        } else if user.role == "parent", let child = selectedChild {
            if let childID = child.id {
                taskViewModel.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: userID, assignedTo: childID, iconName: selectedIcon, colorHex: selectedColor)
            } else {
                print("🚨 Fel: child.id är nil")
            }
        }

        showAddTaskView = false
    }
}


#Preview {
    AddTaskView(showAddTaskView: .constant(true))
        .environmentObject(TaskViewModel.shared)
        .environmentObject(AuthViewModel())
}


