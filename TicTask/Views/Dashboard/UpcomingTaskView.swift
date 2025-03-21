//
// UpcomingTaskView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

struct UpcomingTaskView: View {
    var task: Task

    var body: some View {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: task.colorHex).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: task.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(hex: task.colorHex))
                }

                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)
                    Text(task.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "Ingen deadline")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Spacer()
            }
            .padding()
    }
}
