//
//  TaskOverviewView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-15.
//
import SwiftUI
import Firebase

struct TaskOverviewView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel

    var body: some View {
        SectionBox(title: "Barnens uppgifter") {
            VStack {
                ForEach(taskViewModel.tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            
                            //Modify to get the right tasks
                            
                            Text("Deadline: \(task.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "Ingen")")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        Spacer()
                        Image(systemName: task.iconName)
                            .foregroundColor(Color(hex: task.colorHex))
                    }
                    .padding()
                }
            }
        }
    }
}
