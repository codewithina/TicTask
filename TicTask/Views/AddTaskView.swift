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
    @State private var xpReward: Int = 10

    var body: some View {
        VStack {
            TextField("Titel", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Beskrivning", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Stepper("XP Belöning: \(xpReward)", value: $xpReward, in: 5...50, step: 5)
                .padding()

            Button(action: {
                if let user = authViewModel.user {
                    taskViewModel.addTask(title: title, description: description, xpReward: xpReward, createdBy: user.id, assignedTo: user.id)
                    showAddTaskView = false
                }
            }) {
                Text("Lägg till läxa")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}
