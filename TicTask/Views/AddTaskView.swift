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
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var deadline: Date = Date()
    @State private var xpReward: Int = 10
    @State private var selectedChild: String = ""
    
    var body: some View {
        VStack {
            TextField("Titel", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Beskrivning", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
            
            Stepper("XP Belöning: \(xpReward)", value: $xpReward, in: 5...50, step: 5)
                .padding()
            
            if let user = authViewModel.user, user.role == "parent", let children = user.children, !children.isEmpty {
                Picker("Välj barn", selection: $selectedChild) {
                    Text("Välj ett barn").tag("")

                    ForEach(children, id: \.self) { childID in
                        Text(authViewModel.childrenNames[childID] ?? "Okänt namn")
                            .tag(childID)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
            }
            
            Button(action: {
                if let user = authViewModel.user {
                    if user.role == "child" {
                        // Children adding tasks to themselves
                        taskViewModel.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: user.id, assignedTo: user.id)
                        showAddTaskView = false
                    } else if user.role == "parent", !selectedChild.isEmpty {
                        // Parents must choose a child to be able to add task
                        taskViewModel.addTask(title: title, description: description, deadline: deadline, xpReward: xpReward, createdBy: user.id, assignedTo: selectedChild)
                        showAddTaskView = false
                    }
                }
            }) {
                Text("Lägg till läxa")
                    .padding()
                    .background((authViewModel.user?.role == "parent" && selectedChild.isEmpty) ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(authViewModel.user?.role == "parent" && selectedChild.isEmpty)
        }
        .padding()
    }
}
