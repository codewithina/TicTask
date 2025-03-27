//
//  StreakSummaryView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.

import SwiftUI

struct StreakSummaryView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    let userID: String
    @State private var streakDays = 0
    
    var body: some View {
        VStack {
            if taskViewModel.tasks.isEmpty {
                ProgressView("Laddar streak...")
            } else {
                Text("\(streakDays) dagar utan missade deadlines!")
                    .font(.headline)
                    .foregroundColor(streakDays >= 3 ? .orange : .gray)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                streakDays = taskViewModel.calculateStreakDays(for: userID)
            }
        }
    }
}

